#!/bin/sh

# STLs first
# plates
openscad -o stls/corner_bracket_pair.stl -D part=1 angled_belter.scad &
openscad -o stls/spacer_plates.stl -D part=2 angled_belter.scad &
openscad -o stls/y_plate.stl -D part=3 angled_belter.scad &
openscad -o stls/y_front_plate.stl -D part=33 angled_belter.scad &


# rollers
openscad -o stls/roller_mount.stl -D part=4 angled_belter.scad &
openscad -o stls/roller_drive_mount.stl -D part=5 angled_belter.scad &
openscad -o stls/roller_drive_gear.stl -D part=6 angled_belter.scad &

# hotend
openscad -o stls/y_gantry.stl -D part=7 angled_belter.scad &
openscad -o stls/extruder.stl -D part=8 angled_belter.scad &
openscad -o stls/fan_mount.stl cooling_fan_mount.scad &

# extras
openscad -o stls/rubber_foot.stl -D part=9 angled_belter.scad &

# Everything that can be lasered, should be :-)
openscad -o dxfs/corner_bracket_pair.dxf -D part=1.5 angled_belter.scad &
openscad -o dxfs/spacer_plates.dxf -D part=2.5 angled_belter.scad &
openscad -o dxfs/y_plate.dxf -D part=3.5 angled_belter.scad &
openscad -o dxfs/y_front_plate.dxf -D part=33.5 angled_belter.scad &
