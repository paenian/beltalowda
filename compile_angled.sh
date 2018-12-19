#!/bin/sh

# STLs first
# plates
openscad -o dxfs/spacer_plates.dxf -D part=1 angled_belter_2.scad &
openscad -o dxfs/y_plates.dxf -D part=2 angled_belter_2.scad &
openscad -o dxfs/bed_plates.dxf -D part=3 angled_belter_2.scad &

# y axis
openscad -o stls/y_bracket.stl -D part=5 angled_belter_2.scad &
openscad -o stls/y_bracket_shifted.stl -D part=6 angled_belter_2.scad &
openscad -o stls/y_gantry.stl -D part=7 angled_belter_2.scad &




# rollers
openscad -o stls/roller_mount.stl -D part=4 angled_belter.scad &
openscad -o stls/roller_drive_mount.stl -D part=5 angled_belter.scad &
openscad -o stls/roller_drive_gear.stl -D part=6 angled_belter.scad &

# hotend
openscad -o stls/y_gantry.stl -D part=7 angled_belter.scad &
openscad -o stls/extruder.stl -D part=9 angled_belter.scad &
openscad -o stls/fan_mount.stl cooling_fan_mount.scad &
openscad -o stls/y_endcap.stl -D part=8 angled_belter.scad &

# extras
openscad -o stls/rubber_foot.stl -D part=10 angled_belter.scad &

# Everything that can be lasered, should be :-)
openscad -o dxfs/corner_bracket_pair.dxf -D part=1.5 angled_belter.scad &
openscad -o dxfs/spacer_plates.dxf -D part=2.5 angled_belter.scad &
openscad -o dxfs/y_plate.dxf -D part=3.5 angled_belter.scad &
openscad -o dxfs/y_front_plate.dxf -D part=33.5 angled_belter.scad &
