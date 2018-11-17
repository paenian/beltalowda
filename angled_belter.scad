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
x_bearing_flange = 31.5;
x_bearing_flange_rad = 42/2;
x_bearing_rad = 21/2;

back_flange_rad = 36.5/2;
back_nut_rad = 20/2;
back_screw_sep = 26.4;

//x_nut_rad = 10.3/2;
//x_nut_screw_rad = 16/2;

linear_rail_width = 12;
linear_rail_height = 8;


//positioning offsets
//offset of the rear x bar
x_rear_rad = x_bearing_flange/2+wall+1;
x_offset = -length/2+x_rear_rad;

roller_offset_rear = x_offset+x_rod_sep+x_bearing_flange/2+roller_rad+wall;

echo(big_teeth/small_teeth);

bracket_thick = 6;

z_rear_offset = 100;
bed_lift = roller_rod_rad+roller_rad; //in*1/16; //put a little insulation under the bed beams

chamfer = 1.5;

part = 100;
mirror = 0;

if(part == 1){
    echo("Print 2 sets of corner brackets");
    translate([beam+.5,0,0]) mirror([1,0,0]) side_bracket(feet=false, corner=true);
    translate([-beam-.5,0,0]) side_bracket(feet=false, corner=true);
}

if(part == 1.5){
    echo("Cut 2 sets of corner brackets");
    projection(){
        translate([beam+.5,0,0]) mirror([1,0,0]) side_bracket(feet=false, corner=true);
        translate([-beam-.5,0,0]) side_bracket(feet=false, corner=true);
    }
}

if(part == 2){
    echo("print both spacer plates");
    translate([-beam*2.4,0,0]) spacer_plate();
    mirror([1,0,0]) translate([-beam*2.4,0,0])  spacer_plate();
}

if(part == 2.5){
    echo("Lasercut both spacer plates");
    projection() {
        translate([-beam*2.355,0,0]) spacer_plate();
        mirror([1,0,0]) translate([-beam*2.355,0,0])  spacer_plate();
    }
}

if(part == 3){
    y_plate();
}

if(part == 3.5){
    projection() {
        translate([-beam*.5,0,0]) y_plate();
        mirror([1,0,0]) translate([-beam*.5,0,0]) y_plate(front=true);
    }
}

if(part == 33){
    y_plate(front = true);
}

if(part == 33.5){
    projection() y_plate(front = true);
}

if(part == 4){
    echo("Print 3 roller mounts!");
    mirror([0,0,1]) roller_mount();
}

if(part == 5){
    echo("Print 1 roller drive mounts!");
    mirror([0,0,1]) roller_drive_mount();
}

if(part == 6){
    echo("Print 1 roller drive gear!");
    mirror([0,0,1]) motor_drive_gear();
}

if(part == 7){
    echo("Print one y gantry");
    y_gantry();
}

if(part == 8){
    echo("Print one y endcap");
    endcap();
}

if(part == 9){
    echo("Print one extruder assembly");
    extruder();
}

if(part == 10){
    echo("Print 6ish feet");
    rubber_foot();
}

if(part == 100){
    assembled();
}
module assembled(){
    frame();
    
    //side brackets
    *for(i=[0]) for(j=[0,1]) mirror([j,0,0])
        translate([-length/2-bracket_thick/2,i*(length/2-beam*3),0]) rotate([0,-90,0]) rotate([0,0,-90]) render() side_bracket(feet=true);
    
    //corner brackets
    for(i=[0,1]) for(j=[0,1]) mirror([j,0,0]) mirror([0,i,0])
        translate([-length/2-bracket_thick/2,length/2,beam]) mirror([i,0,0]) rotate([0,-90,0]) rotate([0,0,-90]) render() side_bracket(feet=true, corner=true);
    
    for(i=[0,1]) mirror([i,0,0]) translate([-length/2+beam+bracket_thick/2,0,beam*1.5]) rotate([0,90,0]) {
        render() spacer_plate();
    } 
    
    //y axis
    translate([0,0,beam*1.5]) rotate([0,90,0]) {
        render() y_plate(front = false);
        render() translate([0,0,bracket_thick]) y_plate(front = true);
    }
}

module frame(){
    //base
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,-length/2,0]) rotate([0,90,0]) rotate([-90,0,0]) render() beam_2060(height = length, v=false);
      
      //don't think this is necessary - the feet will handle the separation.  Or maybe should have this, but no feet...
    for(i=[0,1]) mirror([0,i,0]) translate([-length/2,length/2+beam/2,0]) rotate([0,90,0]) rotate([0,0,0]) render() beam_2060(height = length, v=false);
        
    //bottom 'feet'
    *for(i=[-1,0,1]) translate([-length/2,i*length/2,-beam*2]) rotate([90,0,0]) rotate([0,90,0]) render() beam_2040(height = length, v=false);
    
    
    //y rollers
    for(i=[0,1]) translate([0,roller_offset_rear+i*roller_span,beam*1.5+roller_rod_rad]) rotate([90,0,0]) rotate([0,90,0]) {
        cylinder(r=roller_rad, h=roller_len, center=true);
        cylinder(r=roller_rod_rad, h=length, center=true);
    }
    
    //bed beams
    for(j=[1.5]) for(i=[0:6]) translate([-length/2,roller_offset_rear+roller_rad+beam+i*beam*2,beam*2*j]) rotate([90,0,0]) rotate([0,90,0]) render() beam_2040(height = length, v=false);
}

//this goes on the end of the Y axis and tensions the belt.
module endcap(length = 29){
    min_rad = wall/2;
    difference(){
        union(){
            minkowski(){
                cube([linear_rail_width+wall, linear_rail_height+wall, length+wall], center=true);
                sphere(r=min_rad, $fn=6);
            }
            
            //belt pulley mount
            translate([0,-linear_rail_height/2-wall/2,0]) rotate([90,0,0]) cylinder(r1=linear_rail_width/2+wall, r2=m5_rad+.75, h=wall+bracket_thick);
        }
        
        //rail cutout
        translate([0,0,-wall*3-slop]) cube([linear_rail_width+slop*2, linear_rail_height+slop*2, length+slop*2], center=true);
        
        //tensioner
        translate([0,0,length/2+wall]){
            translate([0,0,-wall*2+m5_nut_height+1+.25]) cylinder(r=m5_rad, h=length);
            
            translate([0,0,-wall*2]){
                cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=m5_nut_height+1, $fn=6);
            
                //place to insert the nut
                hull(){
                    translate([0,0,-length-wall]) cylinder(r=m5_nut_rad+1, h=.1);
                    cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=.1, $fn=6);
                }
            }
        }
        
        //belt nut and shaft
        translate([0,-linear_rail_height/2,0]) rotate([90,0,0]){
            cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=m5_nut_height+1, $fn=6);
            
            //place to insert the nut
            hull(){
                translate([0,0,-linear_rail_height-wall]) cylinder(r=m5_nut_rad+1, h=.1);
                cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=.1, $fn=6);
            }
            
            //shaft
            rotate([0,0,180]) cap_cylinder(r=m5_rad, h=50, center=true);
        }
    }
}

screw_mount_rad = 5;
screw_mount_screw_sep = 20;
module y_gantry(){
    //holes are m3, ~5mm deep.
    hole_sep_x = 20;
    hole_sep_y = 20;
    hole_rad = m3_rad;
    hole_cap_rad = m3_cap_rad;
    hotend_extend = 20;
    hotend_y_offset = -5;
    pulley_rad = 6;
    
    
    difference(){
        union(){
            //body
            hull() for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([hole_sep_x/2, hole_sep_y/2, 0]){
               cylinder(r=hole_rad+wall,h=bracket_thick/2, center=true);
                cylinder(r=hole_rad+wall/2,h=bracket_thick, center=true);
            }
            //belt mount
            mirror([0,1,0]) translate([0,pulley_rad+1,bracket_thick]) hull(){
                cube([hole_sep_x+wall*2,wall,7],center=true);
                translate([0,0,-bracket_thick]) cube([hole_sep_x+hole_rad*2+wall*2,wall,1],center=true);
                translate([0,wall,-bracket_thick]) cube([hole_sep_x+hole_rad*2+wall,wall,1],center=true);
            }
            
            //hotend clamp mount
            translate([0,hotend_y_offset,hotend_extend]) rotate([-90,0,0]) groovemount_screw(height = hotend_extend);
        }
        
        //gantry attach holes
        for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([hole_sep_x/2, hole_sep_y/2, 0]){
            cylinder(r1=hole_cap_rad, r2=hole_cap_rad-3, h=bracket_thick*3);
            cylinder(r=hole_rad,h=bracket_thick*6, center=true);
        }
        
        //belt passthrough
        for(i=[0]) mirror([0,i,0]) translate([0,pulley_rad+1,bracket_thick]) hull(){
            cube([100,3,8],center=true);
            translate([0,5,5]) cube([100,3,8],center=true);
        }
        
        //belt grip
        for(i=[1]) mirror([0,i,0]) translate([0,pulley_rad+1,bracket_thick]){
            difference(){
                translate([0,0,4]) cube([100,2.25,8+8],center=true);
                
                for(i=[-15:2:15]) hull(){
                    translate([i,-1,-1]) cube([1,2,8], center=true);
                    translate([i,-1.5,-.5]) cube([1,2,8], center=true);
                }
            }
        }
        
        //hotend clamp holes
        //hotend clamp mount
            translate([0,hotend_y_offset,hotend_extend]) rotate([-90,0,0]) groovemount_screw(height = hotend_extend, solid=0);
    }
}

module groovemount_screw(solid=1,e3d=1, height = 19){
    dia = 16;
    rad = dia/2+slop;
    mink = 1;
    inset = 3;
    groove = 9+2;
    thick = 5;
    length = 10;
    heatsink_rad = 22.5/2;
    hotend_len = 63; //length from top to nozzle tip
    
    bowden_tube_rad = 2.5;
    
    base_rad=screw_mount_rad+3;
    
    screw_inset = 4.2;
    screw_offset = rad+1;
    screw_height = rad+m3_nut_height+wall;

    filament_height = 14;

    if(solid){
        //body
            //screwmount mount
            translate([0,0,-inset+4.25+6/2-slop]) hull(){
                for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,0]) rotate([90,0,0]){
                    cylinder(r=screw_mount_rad, h=height, center=true);
                    translate([0,base_rad-screw_mount_rad,-height/2]) cylinder(r=base_rad, h=1, center=true);
                }
            }
    }else{
        
        //screwmount
        translate([0,0,-inset+4.25+6/2-slop]){
            for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,0]) rotate([90,0,0]) {
                translate([0,0,-wall+m3_nut_height/2+.5+.3]) rotate([0,0,180]) cap_cylinder(r=m3_rad, h=25);
                translate([0,0,-28+-wall+m3_nut_height/2+.5+.3]) rotate([0,0,180]) cap_cylinder(r=m3_rad, h=25);
                
                //nuts
                translate([0,0,-wall]) rotate([0,0,45]) cylinder(r2=m3_sq_nut_rad, r1=m3_sq_nut_rad+1, h=m3_nut_height+1, center=true, $fn=4);
                hull(){
                    translate([0,m3_sq_nut_rad/2,-wall]) rotate([0,0,45]) cylinder(r2=m3_sq_nut_rad, r1=m3_sq_nut_rad+1, h=m3_nut_height+1, center=true, $fn=4);
                    translate([0,m3_sq_nut_rad*2,-wall]) rotate([0,0,45]) cylinder(r2=m3_sq_nut_rad+.5, r1=m3_sq_nut_rad+1.5, h=m3_nut_height+1, center=true, $fn=4);
                }
                
                %translate([0,0,+2]) cylinder(r=m3_rad, h=25.4*3/4);
            }
        }
        
        //draw in the hotend for reference
        %union(){
            cylinder(r=dia/2, h=hotend_len-10, center=false);
            cylinder(r=1, h=hotend_len, center=false);
        }
        
        //hotend holes
       render(){
           //PTFE tube hole
           translate([0,0,-inset-wall*2]) {
               cap_cylinder(r=bowden_tube_rad, h=wall*3);
               translate([0,-3+.75,wall*1.5])
               hull(){
                cube([1,wall*2,wall*3], center=true);
                translate([0,-bowden_tube_rad,0]) cube([bowden_tube_rad*2,wall*2,wall*3], center=true);
               }
           }
           //top part
           translate([0,0,-inset-2]) hull(){
               cap_cylinder(r=4+slop, h=wall);
               translate([0,-3,0]) cap_cylinder(r=4+slop, h=wall);
           }
           
           //the groove
           translate([0,0,-inset]) hull(){
               cap_cylinder(r=12/2+slop*3, h=13, $fn=90);
               translate([0,-3,0]) cap_cylinder(r=12/2+slop*3, h=13, $fn=90);
           }
           
           translate([0,0,-inset]) difference(){
               cap_cylinder(r=rad, h=4+groove+.2+10, $fn=90);
               translate([0,0,4.25]) cylinder(r=rad+1, h=6-slop*3);
           }
       }
        
        //backstop
        translate([0,0,-inset]) cylinder(r=rad+slop*2, h=slop*2);
        
        //clamp cutout
        translate([0,-rad-1.5,-inset+20]) cube([rad*2+wall*3+20,rad*2,100], center=true);
    }
}

module groovemount_screw_clamp(){
    groove_lift = 1;
    wall = 3;
    dia = 16;
    rad = dia/2+slop;
    mink = 1;
    inset = 3;
    groove = 9+2;
    thick = rad-1;
    length = 10;
    
    difference(){
        hull(){
            //screwhole mounts
            for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,0]) cylinder(r=screw_mount_rad, h=thick);
        }
        
        //screwholes
        for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,-1]) cylinder(r=m3_rad+slop, h=wall*4);
        
       //hotend inset
       render() translate([0,3,rad+groove_lift]) rotate([-90,0,0]) {           
           //top part
           translate([0,0,-inset-2]) hull(){
               cap_cylinder(r=4+slop, h=wall);
               translate([0,-3,0]) cap_cylinder(r=4+slop, h=wall);
           }
           
           //the groove
           translate([0,0,-inset]) hull(){
               cap_cylinder(r=12/2+slop*3, h=13, $fn=90);
               translate([0,-3,0]) cap_cylinder(r=12/2+slop*3, h=13, $fn=90);
           }
           
           translate([0,0,-inset]) difference(){
               cap_cylinder(r=rad, h=4+groove+.2, $fn=90);
               translate([0,0,4.25]) cylinder(r=rad+1, h=6-slop*3);
           }
       }
    }
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

module y_plate(front = false){
    motor_offset = -motor_w/2-x_bearing_rad-wall-13;
    motor_rear_offset = -29;
    
    beam_offset = [motor_w/2+linear_rail_width/2,-motor_w/2,linear_rail_width/2];
     
    translate([0,x_offset,0]) difference(){
        union(){
            hull(){
                //flanged bearings
                for(i=[0,1]) translate([-x_rod_rad,x_rod_sep*i,0])
                    for(j=[45:90:359]) rotate([0,0,j]) translate([0,x_bearing_flange/2,0]) cylinder(r=m3_rad+wall/2, h=bracket_thick, center=true);
                
                //y motor
                translate([motor_offset,x_rod_sep/2-motor_rear_offset,0]) rotate([0,0,angle]) motor_body(extra = 4, thick=bracket_thick);
                
                //extruder motor   
                translate([motor_offset,x_rod_sep/2-motor_rear_offset,0]) rotate([0,0,angle]) translate([-motor_w,0,0]) motor_body(extra = 4, thick=bracket_thick);
            }
            
            //beam mount
            translate([motor_offset,x_rod_sep/2-motor_rear_offset,0]) rotate([0,0,angle]) hull(){
                motor_body(extra = 4, thick=bracket_thick);
                if(front == true){
                    translate([0,beam*2.5/2,0]) cube([beam,beam*2.5,bracket_thick],center=true);
                }else{
                    translate([0,beam*4.5/2,0]) cube([beam,beam*4.5,bracket_thick],center=true);
                }
            }
        }
        
        //x drive nut
        translate([-motor_w/2,x_rod_sep/2,0]){
            cylinder(r = back_nut_rad, h=bracket_thick+1, center=true);
                for(j=[90:180:359]) rotate([0,0,j]) translate([0,back_screw_sep/2,0]) cylinder(r=m4_rad, h=bracket_thick+1, center=true);
            %translate([0,0,bracket_thick+2.1]) mirror([0,0,1]) backlash_nut();
        }
        
        
        //x bearing flanges
        for(i=[0,1]) translate([-x_rod_rad,x_rod_sep*i,0]) {
                cylinder(r=x_bearing_rad, h=bracket_thick+1, center=true);
            
            for(j=[45:90:359]) rotate([0,0,j]) translate([0,x_bearing_flange/2,0]) cylinder(r=m4_rad, h=bracket_thick+1, center=true);
                
            %translate([0,0,-bracket_thick]) lm12uuf();
        }
        
        //y motor
        translate([motor_offset,x_rod_sep/2-motor_rear_offset,0]) rotate([0,0,angle]) motor_holes(slot=.5);
        
        //extruder motor
        translate([motor_offset,x_rod_sep/2-motor_rear_offset,0]) rotate([0,0,angle]) translate([-motor_w,0,0]) motor_holes(slot=.5);
        
        //beam mounting holes
        translate([motor_offset,x_rod_sep/2-motor_rear_offset,0]) rotate([0,0,angle]){
            //mounting holes for the rail - no backing beam
            #for(i=[0:3]) translate(beam_offset+[0,12.5+25*i,-bracket_thick/2]) {
                cylinder(r=m3_rad, h=bracket_thick+1, center=true);
            }
            
            //the end of the rail is set into a slot
            if(front == true){
                translate(beam_offset+[0,beam*2,-bracket_thick/2]) cube([linear_rail_width,beam*4,bracket_thick+1],center=true);
                
                //draw in the beam
                %translate(beam_offset+[0,length/2,0]) cube([linear_rail_width, length, linear_rail_width], center=true);
                
                //and rough in the carriage
                %translate(beam_offset + [0,73,linear_rail_width]) rotate([0,0,-90]) render() y_gantry();
            }
        }
    }
}

module backlash_nut(){
    //flange
    cylinder(r=back_flange_rad, h=5);
    
    //screws
    for(i=[0,1]) mirror([i,0,0]) translate([back_screw_sep/2,0,0]) cylinder(r=m4_rad, h=25, center=true);
    
    //shaft
    cylinder(r=back_nut_rad, h=23);
}

module lm12uuf(){
      translate([0,0,-3]) cylinder(r=x_bearing_rad, h=57);
            
      intersection(){
          cube([x_bearing_flange, x_bearing_flange, 6], center=true);
          cylinder(r=x_bearing_flange_rad, h=7, center=true);
      }
            
}

module spacer_plate(){
    width = beam*2;
   
    z_motor_lift = x_rod_rad*2.5;
    z_motor_offset = sqrt(pow(distance_between_axles,2) - pow(motor_w/2-roller_rod_rad+z_motor_lift,2));
    
    
    difference(){
        union(){
            hull(){
                //roller meat
                translate([-roller_rod_rad,roller_offset_rear,0]) rod_clamp(rad=roller_rod_rad+slop, solid=1);
            
                //x axis meat
                translate([0,x_offset,0]) {
                    for(i=[0:1]) translate([-x_rod_rad,x_rod_sep*i,0])
                        cylinder(r=x_rear_rad,h=bracket_thick, center=true);
                }
                
                //screw bosses to mount the thing
                for(i=[0,6]) translate([beam*1.25,x_offset+beam*i,0])
                    cylinder(r=x_rear_rad,h=bracket_thick, center=true);
                
                *translate([beam*1.25,2+roller_offset_rear+motor_w,0])
                    rod_clamp(rad=x_rod_rad+slop, solid=1, wall=4);
                *translate([-x_rod_rad,-length/2+roller_offset_rear+motor_w,0])
                    rod_clamp(rad=x_rod_rad+slop, solid=1, wall=4);
            }
            
            //x axis drive motor
            translate([0,x_offset,0])
                translate([-motor_w/2,x_rod_sep/2,0]) motor_body(extra = 4, thick=bracket_thick);
            
            //z axis drive motor
            translate([-motor_w/2-z_motor_lift,roller_offset_rear-z_motor_offset,0]) motor_body(extra = 4, thick=bracket_thick);
        }
        
        //roller mount
        translate([-roller_rod_rad,roller_offset_rear,0]) rod_clamp(rad=roller_rod_rad+laser_slop, solid=0);
        
        //x axis
        translate([0,x_offset,0]) {
            translate([-motor_w/2,x_rod_sep/2,0]) motor_holes(slot=.5);
            for(i=[0:1]) translate([-x_rod_rad,x_rod_sep*i,0])
                rod_clamp(rad=x_rod_rad+laser_slop, solid=0);
        }
        
        //z axis drive motor
        translate([-motor_w/2-z_motor_lift,roller_offset_rear-z_motor_offset,0]) motor_holes(slot=.5);
        
        //screwholes all over
        for(i=[0,3,6]) translate([beam*1.5,x_offset+beam*i,0]){
            cylinder(r=m5_rad,h=bracket_thick*3, center=true);
            cylinder(r=m5_cap_rad, h=bracket_thick*2);
        }
        for(i=[1.5,4.5]) translate([beam*.5,x_offset+beam*i,0]){
            cylinder(r=m5_rad,h=bracket_thick*3, center=true);
            cylinder(r=m5_cap_rad, h=bracket_thick*2);
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
    
    lift = gear_thick+5;
    
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
                    for(i=[beam/2]) for(j=[-beam,0]) translate([i,j,0]){
                        cylinder(r=beam/2, h=thick-chamfer, center=true);
                        cylinder(r=beam/2-chamfer, h=thick, center=true);
                    }
                    for(i=[-beam/2, beam/2]) for(j=[-beam]) translate([i,j,0]){
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