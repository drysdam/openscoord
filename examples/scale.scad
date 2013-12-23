/* 

Always make image 1000x1000 pixels. If camera is placed 5000 units
away, it is 1 unit = 1 pixel.

If object is too big to fit in that space (>1000 pixels tall), go
10000 units. Now 2 units is 1 pixel.

It scales linearly, so:

    1) Back the camera up until the entire thing fits in there, with
       enough space for dimension lines, a title block, etc. Let that
       distance be D.

    2) Let s = 5000/D. There are now s pixels per unit. So if the
    distance in units is 375, then draw a line s * 375 pixels long.

*/

// For example, say I have this item:
cube(2700,2700,2700, center=true);

// It looks good when I back to about 20000 units from the origin.
//     s = 5000/20000 = 1/4 

// I want to put a line on the drawing of the same length as the side
// of the cube. 2700 * 1/4 = 675. So a command like this will draw
// that line:

openscad --render --imgsize=1000,1000 --projection=o --camera=0,0,0,180,0,0,20000 examples/scale.scad -o examples/scale.png && convert -draw "line 100,100 675,100" examples/scale.png examples/scale_dims.png && display examples/scale_dims.png


