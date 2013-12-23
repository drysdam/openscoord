openscoord
==========

About
-----

OpenSCAD is really cool. I love that I can save meaningful diffs. I
love that I can exploit skills I already have (typing) or want to
learn (mechanical design) without having to acquire a skill I don't
want to spend time on (proficiency with a particular and expensive
piece of proprietary software).

However, I want to produce drawings for use with manual machines and
OpenSCAD doesn't do that. This tool fills that gap. I wouldn't build a
nuclear power plant with it, but if you have a certain casual and
reckless attitude, it works.

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

 - plane or line datums
 - intelligent dimension placement
 - openscad -> image plane coordinate transform
 - info block
 - internal features how??
   - (use a drawing with a difference() that does the cutaway,
     revealing the feature)
 - angular dimensions
