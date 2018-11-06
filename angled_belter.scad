include <configuration.scad>
use <functions.scad>
use <herringbone_gears.scad>

length = 500;
angle = 35;

bed_plate = in*20;
roller_rad = 2.375/2*in;
roller_rod_rad = 5;
roller_drop = 1;
roller_len = in*14;
roller_offset_front = roller_rad+10;
roller_span = 340;


roller_inside_rad = 2.075/2*in-.05;
bearing_rad = 26/2+.125;
bearing_rad = 32/2+.125;    //switch everything to 12mm rods?  Or keep the rollers on 10mm?
bearing_thick = 8;
bearing_thick = 10;
bearing_inset = in;

//belt drive variables
small_teeth = 13;
motor_shaft_rad = 5/2+.2;
big_teeth = 41;
gear_thick = 13;
distance_between_axles = 37;
circular_pitch = 360*distance_between_axles/(small_teeth+big_teeth);

//x axis
x_rod_rad = 6;
x_rod_sep = motor_w+x_rod_rad*4;
x_bearing_flange = 32;
x_bearing_rad = 11;
x_nut_rad = 10.3/2;
x_nut_screw_rad = 16/2;

linear_rail_width = 15;


//positioning offsets
//offset of the rear x bar
x_rear_rad = x_bearing_flange/2+wall+1;
x_offset = -length/2+x_rear_rad;

roller_offset_rear = x_offset+x_rod_sep+x_bearing_flange/2+roller_rad+wall*1.5;

echo(big_teeth/small_teeth);

bracket_thick = 6;

z_rear_offset = 100;
bed_lift = roller_rod_rad+roller_rad; //in*1/16; //put a little insulation under the bed beams

chamfer = 1.5;

part = 99;
mirror = 0;

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
    mirror([mirror,0,0]) roller_bracket(slide = 19);
}

if(part == 4){
    echo("Print 2 fixed brackets");
    mirror([mirror,0,0]) roller_bracket(slide = 0);
}

if(part == 7){
    echo("Print 3 roller mounts!");
    mirror([0,0,1]) roller_mount();
}

if(part == 8){
    echo("Print 1 roller drive mounts!");
    mirror([0,0,1]) roller_drive_mount();
}

if(part == 88){
    echo("Print 1 roller drive mounts!");
    mirror([0,0,1]) motor_drive_gear();
}

if(part == 9){
    projection() spacer_plate();
}
if(part == 99){
    projection() y_plate();
}

if(part == 100){
    assembled();
}
module assembled(){
    frame();
    
    //side brackets
    for(i=[0]) for(j=[0,1]) mirror([j,0,0])
        translate([-length/2-bracket_thick/2,i*(length/2-beam*3),0]) rotate([0,-90,0]) rotate([0,0,-90]) side_bracket(feet=true);
    
    for(i=[-1,1]) for(j=[0,1]) mirror([j,0,0])
        translate([-length/2-bracket_thick/2,i*length/2,0]) rotate([0,-90,0]) rotate([0,0,-90]) side_bracket(feet=true, corner=true);
    
    for(i=[0,1]) mirror([i,0,0]) translate([-length/2+beam+bracket_thick/2,0,beam*1.5]) rotate([0,90,0]) {
        spacer_plate();
    } 
    
    translate([0,0,beam*1.5]) rotate([0,90,0]) {
        y_plate();
    } 
}

module frame(){
    //base
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,-length/2,0]) rotate([0,90,0]) rotate([-90,0,0]) beam_2060(height = length, v=false);
      
      //don't think this is necessary - the feet will handle the separation.  Or maybe should have this, but no feet...
    for(i=[0,1]) mirror([0,i,0]) translate([-length/2,length/2+beam/2,0]) rotate([0,90,0]) rotate([0,0,0]) beam_2060(height = length, v=false);
        
    //bottom 'feet'
    *for(i=[-1,0,1]) translate([-length/2,i*length/2,-beam*2]) rotate([90,0,0]) rotate([0,90,0]) beam_2040(height = length, v=false);
    
    
    //y rollers
    for(i=[0,1]) translate([0,roller_offset_rear+i*roller_span,beam*1.5+roller_rod_rad]) rotate([90,0,0]) rotate([0,90,0]) {
        cylinder(r=roller_rad, h=roller_len, center=true);
        cylinder(r=roller_rod_rad, h=length, center=true);
    }
    
    //bed
    %translate([0,0,beam*1.5+bed_lift]) cube([bed_plate,bed_plate,in/16], center=true);
    %translate([0,0,beam*1.5+bed_lift]) cube([400,400,in/8], center=true);
}

module rod_clamp(rad = 5, wall = 5, solid = 1, h=bracket_thick, angle = 15){
    if(solid == 1){
        cylinder(r=rad+wall*3, h=h, center=true);
        translate([-rad/2-wall/2,0,0]) cube([rad+wall*2,wall*2,h], center=true);
    }else{
        cylinder(r=rad, h=h*2, center=true);
        //open up around the hole top
        intersection(){
            difference(){
                cylinder(r=rad+wall+.1, h=h*2, center=true);
                cylinder(r=rad+wall-1, h=h*3, center=true);
                translate([-rad/2-wall/2,0,0]) cube([rad+wall*2,wall*2,h], center=true);
            }
            //leave the bottom for attachment
            for(i=[0:1]) mirror([0,i,0]) rotate([0,0,90-angle]) translate([0,0,-25]) cube([50,50,50]);
        }
        
        //center gap
        translate([-rad/2-wall/2,0,0]) cube([rad+wall*2+.1,wall/2,h+.1], center=true);
        
        //zip tie clamp
        for(i=[0:1]) mirror([0,i,0]) translate([-rad-wall+1.5,6,0]) {
            cube([4,2,h*3], center=true);
            translate([-1.25,1,0]) cube([6.25,1,h*3], center=true);
        }
        
        translate([-rad-wall*1.5,0,0]) cube([1,wall*2+4,h*2], center=true);
    }
}

module y_plate(){
    motor_offset = -motor_w/2-x_bearing_rad-wall-17;
    translate([0,x_offset,0]) difference(){
        union(){
            hull(){
                //flanged bearings
                for(i=[0,1]) translate([-x_rod_rad,x_rod_sep*i,0])
                    for(j=[45:90:359]) rotate([0,0,j]) translate([0,x_bearing_flange/2,0]) cylinder(r=m3_rad+wall/2, h=bracket_thick, center=true);
                
                translate([motor_offset,x_rod_sep/2,0]) rotate([0,0,angle]) motor_body(extra = 4, thick=bracket_thick);
                translate([motor_offset,x_rod_sep/2,0]) rotate([0,0,angle]) translate([-motor_w,0,0]) motor_body(extra = 4, thick=bracket_thick);
                
            }
            
            //beam mount
            translate([motor_offset,x_rod_sep/2,0]) rotate([0,0,angle]) hull(){
                motor_body(extra = 4, thick=bracket_thick);
                translate([0,beam*4.5/2,0]) cube([beam,beam*4.5,bracket_thick],center=true);
            }
        }
        
        //x drive screw
        translate([-motor_w/2,x_rod_sep/2,0]){
            cylinder(r = x_nut_rad, h=bracket_thick+1, center=true);
                for(j=[45:90:359]) rotate([0,0,j]) translate([0,x_nut_screw_rad,0]) cylinder(r=m3_rad, h=bracket_thick+1, center=true);
        }
        
        
        //x bearing flanges
        for(i=[0,1]) translate([-x_rod_rad,x_rod_sep*i,0]) {
                cylinder(r=x_bearing_rad, h=bracket_thick+1, center=true);
            
            for(j=[45:90:359]) rotate([0,0,j]) translate([0,x_bearing_flange/2,0]) cylinder(r=m3_rad, h=bracket_thick+1, center=true);
        }
        
        //y motor
        translate([motor_offset,x_rod_sep/2,0]) rotate([0,0,angle]) motor_holes();
        
        //extruder motor
        translate([motor_offset,x_rod_sep/2,0]) rotate([0,0,angle]) translate([-motor_w,0,0]) motor_holes();
        
        //beam mounting holes
        translate([motor_offset,x_rod_sep/2,0]) rotate([0,0,angle]){
            //mounting holes for the 2020 beam
            for(i=[0:3]) translate([0,motor_w/2+beam/2+beam*i,0]) {
                cylinder(r=m5_rad, h=bracket_thick+1, center=true);
            }
            
            //2020 is on the motor side, with a linear rail on top - cutout the rail for a little alignment slot.
            translate([0,beam*5,0]) cube([linear_rail_width,beam*4,bracket_thick+1],center=true);
        }
        
        
    }
}

module spacer_plate(){
    width = beam*2;
   
    z_motor_offset = sqrt(pow(distance_between_axles,2) - pow(motor_w/2-x_rod_rad,2));
    
    
    difference(){
        union(){
            hull(){
                //roller meat
                translate([-roller_rod_rad,roller_offset_rear,0]) rod_clamp(r=roller_rod_rad+slop, solid=1);
            
                //x axis meat
                translate([0,x_offset,0]) {
                    for(i=[0:1]) translate([-x_rod_rad,x_rod_sep*i,0])
                        cylinder(r=x_rear_rad,h=bracket_thick, center=true);
                }
                
                //screw bosses to mount the thing
                for(i=[0,8]) translate([beam*1.25,x_offset+beam*i,0])
                    cylinder(r=x_rear_rad,h=bracket_thick, center=true);
                
                *translate([beam*1.25,2+roller_offset_rear+motor_w,0])
                    rod_clamp(r=x_rod_rad+slop, solid=1, wall=4);
                *translate([-x_rod_rad,-length/2+roller_offset_rear+motor_w,0])
                    rod_clamp(r=x_rod_rad+slop, solid=1, wall=4);
            }
            
            //x axis drive motor
            translate([0,x_offset,0])
                translate([-motor_w/2,x_rod_sep/2,0]) motor_body(extra = 4, thick=bracket_thick);
            
            //z axis drive motor
            translate([-motor_w/2,roller_offset_rear+z_motor_offset,0]) motor_body(extra = 4, thick=bracket_thick);
        }
        
        //roller mount
        translate([-roller_rod_rad,roller_offset_rear,0]) rod_clamp(r=roller_rod_rad+laser_slop, solid=0);
        
        //x axis
        translate([0,x_offset,0]) {
            translate([-motor_w/2,x_rod_sep/2,0]) motor_holes();
            for(i=[0:1]) translate([-x_rod_rad,x_rod_sep*i,0])
                rod_clamp(r=x_rod_rad+slop, solid=0);
        }
        
        //z axis drive motor
            translate([-motor_w/2,roller_offset_rear+z_motor_offset,0]) motor_holes();
        
        //screwholes all over
        for(i=[x_offset-x_rod_sep/2,0,-length/2+roller_offset_rear+motor_w]) for(j=[beam*.5,beam*1.5]) translate([j,i,0]){
            cylinder(r=m5_rad, h=bracket_thick*2, center=true);
            //cylinder(r=m5_cap_rad, h=bracket_thickthick*2);
        }
    }
}

module motor_drive_gear(){
    translate([distance_between_axles+1,0,0]) gear1(gear1_teeth = small_teeth, circular_pitch=circular_pitch, gear_height=gear_thick);
}

module roller_drive_mount(wall = 3){
    %motor_drive_gear();
    
    radius = gear_radius(big_teeth, circular_pitch);
    outer_radius = gear_outer_radius(big_teeth, circular_pitch);
    
    gear_chamfer_radius = (outer_radius - radius) / tan(45);
    
    lift = gear_thick+10;
    
    difference(){
        union(){
            
            //roller mount
            translate([0,0,lift]) roller_mount();
            //gear
            chamfered_herring_gear(height=gear_thick, number_of_teeth=big_teeth, circular_pitch=circular_pitch, teeth_twist=-1);
            //connect the two
            translate([0,0,gear_thick-.05]) cylinder(r1=radius, r2=roller_inside_rad+wall, h=lift-gear_thick+.1);
        }
        
        //hollow out a path upwards
        translate([0,0,-.1]) cylinder(r1=bearing_rad+wall*3, r2=bearing_rad+wall*2, h=lift+1);
    }
}

module roller_mount(wall=3){
     difference(){
        union(){
            cylinder(r=roller_inside_rad+wall, h=wall+.1);
            translate([0,0,wall]) cylinder(r1=roller_inside_rad+wall, r2=roller_inside_rad, h=wall+.1);
            translate([0,0,wall*2]) cylinder(r1=roller_inside_rad, r2=roller_inside_rad-slop, h=wall*2+.1);
            translate([0,0,wall*4]) cylinder(r1=roller_inside_rad-slop, r2=bearing_rad+wall*3, h=wall*2+.1);
            translate([0,0,wall*6]) cylinder(r1=bearing_rad+wall*3, r2=bearing_rad+wall*2, h=bearing_inset-wall*5);
            
            translate([0,0,bearing_inset-wall]) hull(){
                cylinder(r=roller_inside_rad, h=wall*2, center=true);
                cylinder(r=roller_inside_rad-wall/2, h=wall*4, center=true);
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

module side_bracket(feet = false, cut = false, thick=bracket_thick, corner=false){    
    difference(){
        union(){
            hull(){
                if(feet == true){
                    translate([0,-beam*3,0]){
                        cylinder(r=beam/2, h=thick-chamfer, center=true);
                        cylinder(r=beam/2-chamfer, h=thick, center=true);
                    }
                    for(i=[-beam/2,beam/2]) for(j=[-beam*2]) translate([i,j,0]){
                        cylinder(r=beam/2, h=thick-chamfer, center=true);
                        cylinder(r=beam/2-chamfer, h=thick, center=true);
                    }
                }
            }
            hull(){
                for(i=[-beam/2,beam/2]) for(j=[-beam*2]) translate([i,j,0]){
                    cylinder(r=beam/2, h=thick-chamfer, center=true);
                    cylinder(r=beam/2-chamfer, h=thick, center=true);
                }
            
                if(corner == true){
                    for(i=[-beam/2, beam/2]) for(j=[-beam,beam]) translate([i,j,0]){
                        cylinder(r=beam/2, h=thick-chamfer, center=true);
                        cylinder(r=beam/2-chamfer, h=thick, center=true);
                    }
                }else{
                    for(i=[0]) for(j=[-beam,beam]) translate([i,j,0]){
                        cylinder(r=beam/2, h=thick-chamfer, center=true);
                        cylinder(r=beam/2-chamfer, h=thick, center=true);
                    }
                }
            }
        }

        for(i=[-10,10]) for(j=[-40,40]) translate([i,j,0]){
            cylinder(r=m5_rad, h=thick*2, center=true);
            cylinder(r=m5_cap_rad, h=thick*2);
        }
        
        if(corner == true){
            for(i=[-beam/2, beam/2]) for(j=[-20,0,20]) translate([i,j,0]){
                cylinder(r=m5_rad, h=thick*2, center=true);
                cylinder(r=m5_cap_rad, h=thick*2);
            }
        }else{
            for(i=[0]) for(j=[-20,0,20]) translate([i,j,0]){
                cylinder(r=m5_rad, h=thick*2, center=true);
                cylinder(r=m5_cap_rad, h=thick*2);
            }
        }
        
        if(feet == true){
            translate([0,-60,0]) cylinder(r=6, h=thick*5, center=true);
        }
    }
}