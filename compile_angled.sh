#!/bin/sh

# STLs first
# plates
openscad -o dxfs/spacer_plates.dxf -D part=1 angled_belter_2.scad &
openscad -o dxfs/y_plates.dxf -D part=2 angled_belter_2.scad &
openscad -o dxfs/bed_plates.dxf -D part=3 angled_belter_2.scad &
openscad -o stls/spacer.dxf -D part=3 extrusion_mounts.scad &

# y axis
openscad -o stls/y_bracket.stl -D part=5 angled_belter_2.scad &
openscad -o stls/y_bracket_shifted.stl -D part=6 angled_belter_2.scad &
openscad -o stls/y_gantry.stl -D part=7 angled_belter_2.scad &
openscad -o stls/y_tensioner.stl -D part=8 angled_belter.scad &

# x tensioner
openscad -o stls/x_tensioner.stl -D part=2 extrusion_mounts.scad &
openscad -o stls/x_rod_slider.stl -D part=1 extrusion_mounts.scad &




# rollers
openscad -o stls/roller_mount.stl -D part=4 angled_belter.scad &
openscad -o stls/roller_drive_mount.stl -D part=5 angled_belter.scad &
openscad -o stls/roller_drive_gear.stl -D part=6 angled_belter.scad &

# extras
openscad -o stls/rubber_foot.stl -D part=10 angled_belter.scad &
