include <configuration.scad>
use <functions.scad>

length = 500;

bed_plate = in*18;
roller_rad = in;
roller_rod_rad = 5;
roller_drop = 1;
roller_len = in*16;
roller_offset = 10;

bracket_thick = 6;

z_rear_offset = 100;
bed_lift = in*1/16; //put a little insulation under the bed beams

part = 100;

if(part == 0){
    echo("Print 6 side brackets!");
    side_bracket(feet=true);
}

if(part == 1){
    echo("Cut 6 side brackets!");
    projection(cut = false) side_bracket(feet=true, cut=true);
}

if(part == 2){
    echo("Print 2 Z brackets!");
    z_bracket();
}

if(part == 2){
    echo("Cut 2 Z brackets!");
    projection(cut = false) z_bracket();
}

if(part == 100){
    assembled();
}
module assembled(){
    frame();
    
    //side brackets
    for(i=[-1,.15,1]) for(j=[0,1]) mirror([j,0,0])
        translate([-length/2-bracket_thick/2,i*(length/2-beam*3),0]) rotate([0,-90,0]) rotate([0,0,-90]) side_bracket(feet=true);
    
    // brackets
    
}

module frame(){
    //base
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,-length/2,0]) rotate([0,90,0]) rotate([-90,0,0]) beam_2040(height = length, v=false);
        
    //bottom 'feet'
    *for(i=[-1,1]) translate([-length/2,i*(length/2-beam),beam/2-beam*2]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    for(i=[-1,.15,1]) translate([-length/2,i*(length/2-beam*3),beam/2-beam*2]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    //belt guide beams
    for(i=[-1,.15,1]) translate([-length/2,i*(length/2-beam*3),beam/2+beam+bed_lift]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    //y rollers
    for(i=[0,1]) mirror([0,i,0]) translate([0,length/2+roller_offset,beam+beam-roller_rad-roller_drop]) rotate([90,0,0]) rotate([0,90,0]) {
        cylinder(r=roller_rad, h=roller_len, center=true);
        cylinder(r=roller_rod_rad, h=length, center=true);
    }
        
    //z rails
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,z_rear_offset,beam]) rotate([0,0,90]) beam_2040(height = length, v=true);
        
    //z top
    translate([-length/2,z_rear_offset,length+beam*1.5]) rotate([0,90,0]) rotate([0,0,90]) beam_2040(height = length, v=false);
    
    //x axis
    translate([-length/2,z_rear_offset-beam-beam/2,length/2]) rotate([0,90,0]) beam_2040(height = length, v=true);
    
    //bed
    %translate([0,0,beam*2+in/16+in/4]) cube([bed_plate,bed_plate,in/16], center=true);
    #translate([0,0,beam*2+in/16+in/4]) cube([400,400,in/8], center=true);
}

module z_bracket(){
    
}

module side_bracket(feet = false, cut = false, thick=bracket_thick){
    chamfer = 1.5;
    difference(){
        union(){
            hull(){
                for(i=[-10,10]) for(j=[-30,30+bed_lift]) translate([i,j,0]){
                    translate([0,0,-chamfer/2]) cylinder(r=10, h=thick-chamfer, center=true);
                    cylinder(r=10-chamfer, h=thick, center=true);
                }
            
                if(feet == true){
                    translate([0,-50,0]){
                        translate([0,0,-chamfer/2]) cylinder(r=10, h=thick-chamfer, center=true);
                        cylinder(r=10-chamfer, h=thick, center=true);
                    }
                }
            }
            
            //stiffening ridge
            if(cut == false) hull(){
                for(i=[-10,10]) for(j=[-30,30+bed_lift]) translate([i,j,0]){
                    translate([0,0,-thick/2]) cylinder(r=chamfer, h=.1);
                }
                translate([0,40+bed_lift-chamfer,0]){
                    translate([0,0,-thick/2]) cylinder(r=chamfer, h=.1);
                }
                if(feet == true){
                    translate([0,-60+chamfer,0]){
                        translate([0,0,-thick/2]) cylinder(r=chamfer, h=.1);
                    }
                }
                
                for(j=[-50,30+bed_lift]) translate([0,j,0]){
                    translate([0,0,-thick/2]) cylinder(r=chamfer, h=thick*2);
                }
            }
        }

        for(i=[-10,10]) for(j=[-30,-10,10,30+bed_lift]) translate([i,j,0]){
            cylinder(r=m5_rad, h=thick*2, center=true);
            cylinder(r=m5_cap_rad, h=thick*2);
        }
        
        if(feet == true){
            translate([0,-50,0]) cylinder(r=5, h=thick*5, center=true);
        }
    }
}