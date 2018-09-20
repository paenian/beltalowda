#!/bin/sh

# brackets
openscad -o stls/side_bracket.stl -D part=0 belter.scad &
openscad -o stls/z_bracket.stl -D part=2 belter.scad &
openscad -o stls/roller_slide_l_bracket.stl -D part=3 -D mirror=0 belter.scad &
openscad -o stls/roller_slide_r_bracket.stl -D part=3 -D mirror=1 belter.scad &
openscad -o stls/roller_fixed_l_bracket.stl -D part=4 -D mirror=0 belter.scad &
openscad -o stls/roller_fixed_r_bracket.stl -D part=4 -D mirror=1 belter.scad &

#roller mounts
openscad -o stls/roller_mount.stl -D part=7 belter.scad &
openscad -o stls/roller_drive_mount.stl -D part=8 belter.scad &
openscad -o stls/motor_drive_gear.stl -D part=88 belter.scad &

