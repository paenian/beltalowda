include <configuration.scad>
use <functions.scad>

length = 500;

bed_plate = in*20;
roller_rad = in;
roller_rod_rad = 5;
roller_drop = 1;
roller_len = in*16;
roller_offset = roller_rod_rad;

roller_inside_rad = 49/2-.2;
bearing_rad = 26/2+.125;
bearing_thick = 8;
bearing_inset = in*2;

bracket_thick = 6;

z_rear_offset = 100;
bed_lift = in*1/16; //put a little insulation under the bed beams

chamfer = 1.5;

part = 4;

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

if(part == 3){
    echo("Print 2 sliding brackets");
    roller_bracket(slide = 19);
}

if(part == 4){
    echo("Print 2 fixed brackets");
    roller_bracket(slide = 0);
}

if(part == 7){
    echo("Print 3 roller mounts!");
    mirror([0,0,1]) roller_mount();
}

if(part == 100){
    assembled();
}
module assembled(){
    frame();
    
    //side brackets
    for(i=[-1,.15,1]) for(j=[0,1]) mirror([j,0,0])
        translate([-length/2-bracket_thick/2,i*(length/2-beam*3),0]) rotate([0,-90,0]) rotate([0,0,-90]) side_bracket(feet=true);
    
    //z brackets
    for(i=[0,1]) mirror([i,0,0]) translate([length/2+bracket_thick/2,z_rear_offset,beam]) rotate([0,90,0]) rotate([0,0,90]) z_bracket();
    
    //y brackets - two adjust to tension the belt, two are fixed.
    for(i=[-1,1]) for(j=[0,1]) mirror([j,0,0])
        translate([-length/2+beam+bracket_thick/2,i*(length/2),0]) rotate([0,-90,0]) mirror([0,0,1]) roller_bracket(slide = 10);
}

module frame(){
    //base
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,-length/2,0]) rotate([0,90,0]) rotate([-90,0,0]) beam_2040(height = length, v=false);
        
    //bottom 'feet'
    *for(i=[-1,1]) translate([-length/2,i*(length/2-beam),beam/2-beam*2]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    for(i=[-1,.15,1]) translate([-length/2,i*(length/2-beam*2),beam/2-beam*2]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    //belt guide beams
    for(i=[-1,.15,1]) translate([-length/2,i*(length/2-beam*2),beam/2+beam+bed_lift]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    //y rollers
    for(i=[0,1]) mirror([0,i,0]) translate([0,length/2+roller_offset,beam/2]) rotate([90,0,0]) rotate([0,90,0]) {
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
    %translate([0,0,beam*2+bed_lift]) cube([bed_plate,bed_plate,in/16], center=true);
    %translate([0,0,beam*2+bed_lift]) cube([400,400,in/8], center=true);
}

module roller_mount(wall=3){
     difference(){
        union(){
            cylinder(r=roller_inside_rad+wall, h=wall+.1);
            translate([0,0,wall]) cylinder(r1=roller_inside_rad+wall, r2=roller_inside_rad, h=wall+.1);
            translate([0,0,wall*2]) cylinder(r1=roller_inside_rad, r2=roller_inside_rad-slop, h=wall+.1);
            translate([0,0,wall*3]) cylinder(r1=roller_inside_rad-slop, r2=bearing_rad+wall*3, h=wall*2+.1);
            translate([0,0,wall*5]) cylinder(r1=bearing_rad+wall*3, r2=bearing_rad+wall*2, h=bearing_inset-wall*4);
            
            translate([0,0,bearing_inset]) hull(){
                cylinder(r=roller_inside_rad, h=wall, center=true);
                cylinder(r=roller_inside_rad-slop*2, h=wall*2, center=true);
            }
        }
        
        //approach the bearing
        translate([0,0,-.1]) cylinder(r1=bearing_rad+wall*2, r2=bearing_rad+wall, h=bearing_inset-bearing_thick+.2);
        //mount the bearing
        translate([0,0,-.1]) cylinder(r2=bearing_rad, r1=bearing_rad+slop/2, h=bearing_inset+.1);
        //center through hole
        translate([0,0,-.1]) cylinder(r=bearing_rad-wall, h=bearing_inset+.2+wall);  
    }
}

module roller_bracket(slide = 0, thick=bracket_thick){
    fillet = beam/4;
    difference(){
        union(){
            //back plate - side extrusions & rod hole/slot
            hull(){
                for(i=[-beam/2,beam/2]) for(j=[beam*.5,beam*2.5]) translate([i,j,0]){
                    cylinder(r=beam/2, h=thick-chamfer*2, center=true);
                    cylinder(r=beam/2-chamfer, h=thick, center=true);
                }
                
                //rod slot
                for(j=[-roller_offset, -roller_offset-slide]) translate([beam/2,j,0]){
                    cylinder(r=beam/2, h=thick-chamfer*2, center=true);
                    cylinder(r=beam/2-chamfer, h=thick, center=true);
                }
            }
            
            //top and bottom beam mounts
            for(i=[0,1]) mirror([i,0,0]) translate([beam-thick/2,0,beam/2-thick/2]) hull() for(j=[beam*1.5,beam*2.5]) translate([0,j,0]) rotate([0,90,0]) {
                cylinder(r=beam/2, h=thick-chamfer*2, center=true);
                cylinder(r=beam/2-chamfer, h=thick, center=true);
            }
            
            //fillet the sides
            for(i=[0,1]) mirror([i,0,0]) translate([beam-thick/2,beam*2,beam/2-thick/2]) rotate([0,90,0]) {    
                translate([10-thick,0,-thick/2]) rotate([90,0,0]) difference(){
                    cylinder(r=fillet, h=beam*2-chamfer*2, center=true);
                    translate([-fillet, -fillet, 0]) cylinder(r=fillet, h=beam*2, center=true);
                }
            }
        }
        
        //side holes
        for(i=[-beam/2,beam/2]) for(j=[beam*.5,beam*2.5]) translate([i,j,0]){
            cylinder(r=m5_rad, h=thick*2, center=true);
            cylinder(r=m5_cap_rad, h=thick*3);
        }
        
        //top and bottom beam mount holes
        for(i=[0,1]) mirror([i,0,0]) translate([-beam+thick/2,0,beam/2-thick/2]) for(j=[beam*1.5,beam*2.5]) translate([0,j,0]) rotate([0,90,0]) {
            cylinder(r=m5_rad, h=thick*2, center=true);
            cylinder(r=m5_cap_rad, h=thick*3);
        }
        
        //rod slot
        hull() for(j=[-roller_offset, -roller_offset-slide]) translate([beam/2,j,0]){
            cylinder(r=roller_rod_rad+slop, h=thick*3, center=true);
        }
    }
}

module z_bracket(cut = false, thick=bracket_thick){
    difference(){
        union(){
            hull(){
                for(i=[-10,10]) for(j=[-30,50]) translate([i,j,0]){
                    translate([0,0,-chamfer/2]) cylinder(r=10, h=thick-chamfer, center=true);
                    cylinder(r=10-chamfer, h=thick, center=true);
                }
                
                for(i=[-30,30]) for(j=[-30]) translate([i,j,0]){
                    translate([0,0,-chamfer/2]) cylinder(r=10, h=thick-chamfer, center=true);
                    cylinder(r=10-chamfer, h=thick, center=true);
                }
            }
            if(cut == false) hull(){
                for(i=[-10,10]) for(j=[-40+chamfer,60-chamfer]) translate([i,j,0]){
                    translate([0,0,-thick/2]) cylinder(r=chamfer, h=.1);
                }
                translate([0,40-chamfer,0]){
                    translate([0,0,-thick/2]) cylinder(r=chamfer, h=.1);
                }
                
                for(j=[-30,50]) translate([0,j,0]){
                    translate([0,0,-thick/2]) cylinder(r=chamfer, h=thick*2);
                }
            }
        }
        
        // screwholes
        for(i=[-10,10]) for(j=[-10,30,50]) translate([i,j,0]){
            cylinder(r=m5_rad, h=thick*2, center=true);
            cylinder(r=m5_cap_rad, h=thick*2);
        }
        
        for(i=[-30,30]) translate([i,-30,0]){
            cylinder(r=m5_rad, h=thick*2, center=true);
            cylinder(r=m5_cap_rad, h=thick*2);
        }
    }
}

module side_bracket(feet = false, cut = false, thick=bracket_thick){
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