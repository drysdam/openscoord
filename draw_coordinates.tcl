#!/usr/bin/env tclsh8.5

proc arrow-on {sx sy ex ey} {
	# draw tip first so it's exactly where the end of the line is
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
set dimsf [lindex $argv 3]

set fh [open $datumf r]
array unset data
while {[gets $fh line] >= 0} {
	set datumdef [lindex [split $line \"] 1]
	lassign [split $datumdef " "] junk name x y z
	set data($name,x) $x
	set data($name,y) $y
	set data($name,z) $z
}
close $fh

set fh [open $dimsf r]
set dimpairs {}
while {[gets $fh line] >= 0} {
	set l [string trim $line]
	if {[string index $l 0] == "#"} { continue }
	lassign [split $l " "] proj d1 d2 style
	if {$proj eq $projecting} {
		lappend dimpairs [list $d1 $d2 $style]
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
	lassign $pair startdatum enddatum style

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
	set dist [distance $startpt $endpt]

	# coordinate transform to image plane
	set sd1 [expr $sd1 + 500]
	set ed1 [expr $ed1 + 500]
	set sd2 [expr 500 - $sd2]
	set ed2 [expr 500 - $ed2]
	set text1 [expr ($sd1 + $ed1)/2.0]
	set text2 [expr ($sd2 + $ed2)/2.0]

	append cmds " -draw \{line $sd1,$sd2 $ed1,$ed2\} -draw \{text $text1,$text2 '$dist'\} "

	set startstyle [string index $style 0]
	set endstyle [string index $style 1]

	if {$startstyle == "."} {
		# plain start, do nothing
	} 
	if {$startstyle == "a"} {
		# arrow on beginning, so draw one on the reversed line
		append cmds [arrow-on $ed1 $ed2 $sd1 $sd2]
	}
	
	if {$endstyle == "."} {
		# plain end, do nothing
	} 
	if {$endstyle == "a"} {
		# arrow on end, so draw one
		append cmds [arrow-on $sd1 $sd2 $ed1 $ed2]
	}
}

#append cmds " -draw {line 500,500 600,600} [arrow-on 500 500 600 600] "

#puts "convert -stroke black {*}$cmds $imginf $imgoutf"
exec convert -stroke black {*}$cmds $imginf $imgoutf
