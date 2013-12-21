pad=1; // to preserve manifold

// for all
height = 125;
echo(str("DATUM FACE-1 0 0 0"));
echo(str("DATUM FACE-2 0 0 ", height));

// ring
outerradius = 250;
innerradius = 375/2.0;
echo(str("DATUM CENTER 0 0 0"));
echo(str("DATUM INNER-RAD 0 ", -innerradius, " 0"));
echo(str("DATUM OUTER-RAD 0 ", outerradius, " 0"));

// stub
width = 5/32 * 1000;
length = 13/32 * 1000;
echo(str("DATUM STUB-END ", length, " 0 0"));
echo(str("DATUM STUB-SIDE-1 ", length, " ", -width/2, " ", 0));
echo(str("DATUM STUB-SIDE-2 ", length, " ", width/2, " ", 0));

// hole for strap arm
armradius = 3/64 * 1000;
armdepth = 125;
echo(str("DATUM STRAP-ARM-DIA-1 ", length, " ", -armradius, " ", height/2));
echo(str("DATUM STRAP-ARM-DIA-2 ", length, " ", armradius, " ", height/2));

// corner radii
toolradius = 1/16 * 1000;
cuthypotenuse = outerradius + toolradius;
cutyleg = toolradius+width/2.0;
cutxleg = sqrt(pow(cuthypotenuse,2) - pow(cutyleg,2));
echo(str("DATUM RADIUS-CENTER ", cutxleg, " ", cutyleg, " 0"));
echo(str("DATUM RADIUS-RAD ", cutxleg, " ", width/2, " 0"));

difference() {
    union() {
		// stub
	    translate (v=[0, -width/2.0, 0]) cube([length, width, height]);
        // outer ring
        cylinder(r=outerradius, h=height, $fn=100);
        // add material to cut radius out of...
    	linear_extrude(height=height) polygon(points=[[cutxleg, cutyleg], [0,0], [cutxleg,-cutyleg]]);
    }

    // eccentric hole
  	translate (v=[0,0,-pad]) cylinder(r=innerradius, h=height+2*pad);

    // ...and cut radius
	union() {
        translate (v=[cutxleg, cutyleg, -1]) cylinder(r=toolradius, h=height+2, $fn=100);
        translate (v=[cutxleg, -cutyleg, -1]) cylinder(r=toolradius, h=height+2, $fn=100);
    }
	
    translate([length+pad,0,height/2]) rotate([0,-90,0]) cylinder(r=armradius, armdepth+pad);	
}    

