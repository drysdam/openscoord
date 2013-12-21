/*
    It's not clear how to handle situations where more than one cutaway is needed. 

    1) Just a note ("3 plcs") if they are all the same
    2) Non-planar cut (standard drafting practice, I think)
    3) Transparent view (pretty, but hard to automatically generate)
*/

LENGTH = 4;
HOLES = 3;
OFFSET = .05;
// actual object
difference() {
   cube([LENGTH, 2, 1], center=true);

   for (i = [1:HOLES]) {
       translate([-LENGTH / 2 + i / (HOLES + 1) * LENGTH, 0, 0])

	   if (floor(i / 2) == i / 2) {
		   translate([0, .375, 0])
		   cylinder(r=.125, h=.5 + OFFSET);
	   } else {
		   translate([0, -.375, 0])
		   cylinder(r=.125, h=.5 + OFFSET);
	   }
   }
}

// non-planar cut view
translate([0,-3,0])
difference() {
   difference() {
      cube([LENGTH, 2, 1], center=true);

      for (i = [1:HOLES]) {
          translate([-LENGTH / 2 + i / (HOLES + 1) * LENGTH, 0, 0])

      if (floor(i / 2) == i / 2) {
	     translate([0, .375, 0])
		 cylinder(r=.125, h=.5 + OFFSET);
	  } else {
	     translate([0, -.375, 0])
		 cylinder(r=.125, h=.5 + OFFSET);
	  }
   }
   translate([-.75,-.675,-1]) cube([1.5,1,2+OFFSET]);
   translate([-3,-1.375,-1]) cube([6,1,2+OFFSET]);
}

}
// transparent view
translate([0,3,0])
union() {
   %cube([LENGTH, 2, 1], center=true);

   for (i = [1:HOLES]) {
       translate([-LENGTH / 2 + i / (HOLES + 1) * LENGTH, 0, 0])

	   if (floor(i / 2) == i / 2) {
		   translate([0, .375, 0])
		   cylinder(r=.125, h=.5 + OFFSET);
	   } else {
		   translate([0, -.375, 0])
		   cylinder(r=.125, h=.5 + OFFSET);
	   }
   }
}
