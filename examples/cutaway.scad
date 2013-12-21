/*
    To generate a regular view and a cutaway view, invoke something
    equivalent to these alternately. (The cut plane would be a kind of
    datum.)
 
    openscad -D "CUT_PLANE_1=false" --render -o examples/cutaway.png examples/cutaway.scad
    openscad -D "CUT_PLANE_1=true" --render -o examples/cutaway.png examples/cutaway.scad
*/
OFFSET = .05;                                                                                                                                                     
$fn = 100;                                                                                                                                                        
difference() {
    difference() {
	    cube([3, 1, 1], center=true);
        translate([-1,0,0]) rotate([0,90,0])  
            cylinder(r=.25, h=1 + OFFSET, center=true);
    }
	if (CUT_PLANE_1==true) {
        translate([-50,-50,0]) cube([100, 100, 100]);
    }
}

