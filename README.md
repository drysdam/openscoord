openscoord
==========

Requirements:
-------------

 - a version of OpenSCAD that can write PNGs
 - Tcl 8.5 or later
 - ImageMagick
 
How to run the example:
-----------------------

1. make sure the png-producing OpenSCAD is in your path. 
2. add `openscoord/` to your path
3. run `scripts/draw_all_coordinates`
4. this should have created 3 orthogonal views of the example part:

    - examples/eccentric-strap-xy.png
    - examples/eccentric-strap-yz.png
    - examples/eccentric-strap-xz.png

   as well as dimensioned versions of the same views 

    - examples/eccentric-strap-xy_dims.png
    - examples/eccentric-strap-yz_dims.png
    - examples/eccentric-strap-xz_dims.png

TODO
----------------

 - dim ends type (arrow vs cross, for instance)
 - plane or line datums
 - intelligent dimension placement
 - tolerances, including handling of fractions
 - openscad -> image plane coordinate transform
 - info block
 - internal features how??

