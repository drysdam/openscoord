#!/usr/bin/env tclsh8.5

proc gcd { a b } {
	set rem [expr $a % $b]
	if {$rem == 0} {
		return $b
	} else {
		return [gcd $b $rem]
	}
}

proc nearest_fraction { inches } {
	set denom 64
	set numer [format %.0f [expr $inches * $denom]]
	set comdiv [gcd $denom $numer]
	set numer [expr $numer/$comdiv]
	set denom [expr $denom/$comdiv]
	set frac "$numer/$denom"
	#puts "$inches -> $frac"
	return $frac
}

# crosshairs aren't directional, so just need a location
proc crosshairs-at {x y} {
	set crosshairs "path 'M -15,0 L +15,0 M 0,-15 L 0,+15'"
    set cmd " -draw \{translate $x,$y $crosshairs\} "
	return $cmd
}

# draws arrow on END tip (reverse line for start)
proc arrow-on {sx sy ex ey} {
	#puts "$sx $sy $ex $ey"
	set arrow_head "path 'M 0,0 l -15,-5  +5,+5  -5,+5  +15,-5 z'"
	set rise [expr ($ey - $sy)]
	set run [expr ($ex - $sx)]
	if {$run == 0} {
		if {$rise > 0} {
			set thetad 90
		} else {
			set thetad 270
		}
	} elseif {$rise == 0} {
		if {$run > 0} {
			set thetad 0
		} else {
			set thetad 180
		}
	} else {
		set thetad [expr atan($rise/$run) * 180/3.14159]
		# determine quadrant for negative runs
		if {$run < 0} {
			set thetad [expr fmod($thetad+180,360.0)]
		}
	}
    set cmd " -draw \{translate $ex,$ey rotate $thetad $arrow_head\} "
	return $cmd
}

# handles any number of dimensions, as long as they are the same for
# both
proc distance {start end} {
#	puts "distance \{$start\} \{$end\}"
	set summedsqs 0
	foreach s $start e $end {
		set summedsqs [expr $summedsqs + pow($e - $s, 2)]
	}
	return [expr sqrt($summedsqs)]
}

set datumf [lindex $argv 0]
set imginf [lindex $argv 1]
set projecting [lindex $argv 2]
set pixelsperunit [lindex $argv 3]

set fh [open $datumf r]
array unset data
set dimpairs {}
while {[gets $fh line] >= 0} {
	set datumdef [lindex [split $line \"] 1]
	set type [lindex $datumdef 0]
	switch -exact -- $type {
		"DATUM" {
			lassign [split $datumdef " "] junk name x y z
			set data($name,x) $x
			set data($name,y) $y
			set data($name,z) $z
		}
		"DIM" {
			lassign [split $datumdef " "] junk proj d1 d2 style format
			if {$proj eq $projecting} {
				lappend dimpairs [list $d1 $d2 $style $format]
			}
		}
	}
}
close $fh

set ext [file extension $imginf]
set extlen [string length $ext]
set ifbase [string range $imginf 0 end-$extlen]
set imgoutf "${ifbase}_dims$ext"

# dim drawing spec needs to specify:
#  - what data
#  - projection plane

if {$projecting eq "x"} {
	set dim1 y
	set dim2 z
} elseif {$projecting eq "y"} {
	set dim1 x
	set dim2 z
} else {
	set dim1 x
	set dim2 y
}

set cmds ""
foreach pair $dimpairs {
	lassign $pair startdatum enddatum style format

	set startpt {}
	set endpt {}
	foreach dim {x y z} {
		if {$dim eq $projecting} { continue }
		if {$dim eq $dim1} {
			set sd1 $data($startdatum,$dim)
			set ed1 $data($enddatum,$dim)
		} else {
			set sd2 $data($startdatum,$dim)
			set ed2 $data($enddatum,$dim)
		}
		lappend startpt $data($startdatum,$dim)
		lappend endpt $data($enddatum,$dim)
	}

	# all numbers (so far) are thous (.001"), so 250 = 1/4"
	set dist [distance $startpt $endpt]
	set thous [expr int($dist)/1000.0]

	switch -exact -- $format {
		"f" {
			set disttext "[nearest_fraction $thous]\""
		}
		"d" {
			set disttext "$thous\""
		}
	}

	# coordinate transform to image plane
	set sp1 [expr $sd1 * $pixelsperunit]
	set ep1 [expr $ed1 * $pixelsperunit]
	set sp2 [expr $sd2 * $pixelsperunit]
	set ep2 [expr $ed2 * $pixelsperunit]

	set sp1 [expr $sp1 + 500]
	set ep1 [expr $ep1 + 500]
	set sp2 [expr 500 - $sp2]
	set ep2 [expr 500 - $ep2]
	set text1 [expr ($sp1 + $ep1)/2.0]
	set text2 [expr ($sp2 + $ep2)/2.0]

	append cmds " -draw \{line $sp1,$sp2 $ep1,$ep2\} -draw \{text $text1,$text2 '$disttext'\} "

	set startstyle [string index $style 0]
	set endstyle [string index $style 1]

	if {$startstyle == "."} {
		# plain start, do nothing
	} 
	if {$startstyle == "+"} {
		# starts with crosshairs, so draw it
		append cmds [crosshairs-at $sp1 $sp2]
	} 
	if {$startstyle == "a"} {
		# arrow on beginning, so draw one on the reversed line
		append cmds [arrow-on $ep1 $ep2 $sp1 $sp2]
	}
	
	if {$endstyle == "."} {
		# plain end, do nothing
	} 
	if {$endstyle == "+"} {
		# ends with crosshairs, so draw it
		append cmds [crosshairs-on $ep1 $ep2]
	} 
	if {$endstyle == "a"} {
		# arrow on end, so draw one
		append cmds [arrow-on $sp1 $sp2 $ep1 $ep2]
	}
}

#append cmds " -draw {line 500,500 600,600} [arrow-on 500 500 600 600] "

#puts "convert -stroke black {*}$cmds $imginf $imgoutf"
exec convert -stroke black {*}$cmds $imginf $imgoutf
