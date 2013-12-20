#!/usr/bin/env tclsh8.5

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
	lassign [split $line " "] proj d1 d2
	if {$proj eq $projecting} {
		lappend dimpairs [list $d1 $d2]
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
	lassign $pair startdatum enddatum

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

	append cmds "-draw \{[list line $sd1,$sd2 $ed1,$ed2]\} -draw \{[list text $text1,$text2 '$dist']\} "
}

exec convert -stroke black {*}$cmds $imginf $imgoutf
#exec convert -stroke black -draw {line 240,500 200,500} -draw {line 240,375 200,375} -draw {text 210,438 ".125"} $imginf $imgoutf