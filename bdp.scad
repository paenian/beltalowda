include <configuration.scad>
use <functions.scad>

frame();
length = 500;

bed_plate = in*18;
roller_rad = in;
roller_drop = 1;
roller_len = in*17;

z_rear_offset = beam/2+beam+1+beam/2+8;

module frame(){
    //base
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,-length/2,0]) rotate([0,90,0]) rotate([-90,0,0]) beam_2040(height = length, v=false);
        
    //bottom 'feet'
    for(i=[-1,1]) translate([-length/2,i*(length/2-beam),beam/2-beam*2]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    //belt guide beams
    for(i=[-1,0,1]) translate([-length/2,i*(length/2-beam*3),beam/2+beam]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    //y rollers
    for(i=[0,1]) mirror([0,i,0]) translate([0,length/2,beam+beam-roller_rad-roller_drop]) rotate([90,0,0]) rotate([0,90,0]) cylinder(r=roller_rad, h=roller_len, center=true);
        
    //z rails
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,z_rear_offset,beam]) rotate([0,0,90]) beam_2040(height = length, v=true);
        
    //z top
    translate([-length/2,z_rear_offset,length+beam*1.5]) rotate([0,90,0]) rotate([0,0,90]) beam_2040(height = length, v=false);
    
    //x axis
    translate([-length/2,z_rear_offset-beam-beam/2,length/2]) rotate([0,90,0]) beam_2040(height = length, v=true);
    
    //bed
    %translate([0,0,beam*2+in/16+in/4]) cube([bed_plate,bed_plate,in/8], center=true);
    %translate([0,0,beam*2+in/16+in/4]) cube([400,400,in/7], center=true);
}