include <configuration.scad>
use <functions.scad>
use <herringbone_gears.scad>

length = 500;
angle = 35;

//roller variables
roller_rad = 2.375/2*in;
roller_rod_rad = 5;
roller_drop = 1;
roller_len = in*14;
roller_span = 340;
roller_inside_rad = 2.075/2*in-.05;

//roller bearings - 10mm rods right now.
bearing_rad = 26/2+.125;
//bearing_rad = 32/2+.125;    //switch everything to 12mm rods?  Or keep the rollers on 10mm?
bearing_thick = 8;
bearing_thick = 10;
bearing_inset = in;

//roller drive variables
small_teeth = 13;
motor_shaft_rad = 5/2+.2;
big_teeth = 41;
gear_thick = 13;
distance_between_axles = 37;
circular_pitch = 360*distance_between_axles/(small_teeth+big_teeth);

//bracket variables
bracket_thick = 6;
chamfer = 1.5;

//x axis variables
linear_rail_width = 12;
linear_rail_height = 8;
linear_rail_carriage_width = 27;
linear_rail_carriage_height = 10;
linear_rail_carriage_length = 34.7;
linear_rail_carriage_offset = 3+(linear_rail_carriage_height-linear_rail_height)/2;

back_flange_rad = 36.5/2;
back_nut_rad = 20/2;
back_screw_sep = 26.4;

//extruder variables
screw_mount_rad = 5;
screw_mount_screw_sep = 20;

2
//positioning variables
x_rail_offset_rear = [0,-length/2-beam/2,0];
x_rail_offset_front = x_rail_offset_rear + [0,71,0];

roller_offset_rear = x_rail_offset_front+[0,roller_rad+19,0];
roller_offset_front = [0,length/2-roller_rad-beam,0];

x_motor_offset = x_rail_offset_rear+[0,motor_w/2+linear_rail_width+wall/2,beam*1.5+motor_w/2];

y_motor_offset = x_motor_offset + [0,motor_w/2+72, motor_w/2];
y_beam_offset = [0,-motor_w/2,0];

bed_height = roller_rad+roller_rod_rad+3;
bed_height = beam*2;
bed_offset_rear = -89;





part = 100;

if(part == 100){
    assembled();
}

module assembled(){
    frame();
    
    rods_and_rails();
    
    //corner brackets
    for(i=[0,1]) for(j=[0,1]) mirror([j,0,0]) mirror([0,i,0])
        translate([-length/2-bracket_thick/2,length/2,beam]) mirror([i,0,0]) rotate([0,-90,0]) rotate([0,0,-90]) render() side_bracket(feet=true, corner=true);
    
    for(i=[0,1]) mirror([i,0,0]) translate([-length/2+beam+bracket_thick/2,0,beam*1.5]) rotate([0,90,0]) {
        render() spacer_plate();
    } 
    
    //y axis
    translate([0,x_offset,beam*1.5]) rotate([0,90,0]) {
        render() y_plate(front = false);
        render() translate([0,0,bracket_thick]) y_plate(front = true);
    }
}

module frame(){
    //base square
    for(i=[0,1]) mirror([i,0,0]) translate([length/2-beam/2,-length/2,0]) rotate([0,90,0]) rotate([-90,0,0]) render() beam_2060(height = length, v=false);
    for(i=[0,1]) mirror([0,i,0]) translate([-length/2,length/2+beam/2,0]) rotate([0,90,0]) rotate([0,0,0]) render() beam_2060(height = length, v=false);
    
    //bed beams
    for(i=[0:6]) translate([-length/2,bed_offset_rear+i*40,bed_height+beam]) rotate([90,0,0]) rotate([0,90,0]) render() beam_2040(height = length, v=false);
}

module rods_and_rails(solid = 0){
    //z rollers
    for(i=[roller_offset_rear,roller_offset_front]) translate(i+[0,0,beam*1.5+roller_rod_rad]) rotate([90,0,0]) rotate([0,90,0]) {
        cylinder(r=roller_rad, h=roller_len, center=true);
        cylinder(r=roller_rod_rad, h=length, center=true);
    }
    
    //x rails
    translate(x_rail_offset_rear+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) linear_rail();
    translate(x_rail_offset_front+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) linear_rail();
    
    //x motor
    translate(x_motor_offset) rotate([0,90,0]) {
        cylinder(r=4, h=length, center=true);
        if(solid != 1) {
            for(i=[0,1]) mirror([0,0,i]) translate([0,0,length/2-beam]) motor_holes();
            
            translate([0,0,bracket_thick]) mirror([0,0,1]) backlash_nut();           
        }
    }
    
    //y motor
    translate(y_motor_offset) rotate([0,90,0]) rotate([0,0,angle]) {
        if(solid != 1) {
            motor_holes();
            
            //y rail
            translate([0,motor_w/2+length/2,0]) rotate([90,0,0]) linear_rail();
            #translate([0,motor_w+37,0]) rotate([0,0,-90]) y_gantry();
        }
    }
}

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

////Standard parts below :-)
module linear_rail(carriage = true){
    cube([linear_rail_width, linear_rail_height, length], center=true);
    translate([0,linear_rail_carriage_offset,0]) cube([linear_rail_carriage_width, linear_rail_carriage_height, linear_rail_carriage_length], center=true);
}

module backlash_nut(){
    //flange
    cylinder(r=back_flange_rad, h=5);
    
    //screws
    for(i=[0,1]) mirror([i,0,0]) translate([back_screw_sep/2,0,0]) cylinder(r=m4_rad, h=25, center=true);
    
    //shaft
    cylinder(r=back_nut_rad, h=23);
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