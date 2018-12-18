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
linear_rail_carriage_screw_sep_w = 20;
linear_rail_carriage_screw_sep_l = 20;
linear_rail_screw_offset = 12.5;
linear_rail_screw_sep = 25;

back_flange_rad = 36.5/2;
back_nut_rad = 20/2;
back_screw_sep = 26.4;

//extruder variables
screw_mount_rad = 5;
screw_mount_screw_sep = 20;

//positioning variables
x_rail_offset_rear = [0,-length/2-beam/2,0];
x_rail_offset_front = x_rail_offset_rear + [0,71,23];

roller_offset_rear = [0,x_rail_offset_front[1] + roller_rad+23,beam*1.5+roller_rod_rad];
roller_offset_front = [0,length/2-roller_rad-beam,beam*1.5+roller_rod_rad];

x_motor_offset = x_rail_offset_rear+[0,motor_w/2+linear_rail_width+wall/2,beam*1.5+motor_w/2];



y_beam_offset = x_motor_offset + [0,motor_w/2, motor_w/2];
y_beam_inset = 9;
y_motor_offset = [-motor_w/2-beam/2, motor_w/2, 0];
y_pulley_offset = y_motor_offset[0];
//The Motor is dependent on the beam - this is an offset from the beam.
y_bracket_hole_lift = linear_rail_carriage_height+13;

bed_height = roller_rad+roller_rod_rad+3;
bed_height = beam*2;
bed_offset_rear = -89;

extruder_offset = y_beam_offset - [0,motor_w*1.5,motor_w/2];

part = 2;

if(part == 1){
    projection(){
        rotate([0,90,0]) translate([-length/2+beam,0,beam/2+.1]) spacer_plate_drive();
        rotate([0,-90,0]) translate([length/2-beam,0,beam/2+.1]) spacer_plate_idler();
    }
}

if(part == 2){
    projection(){
        rotate([0,90,0]) translate([-length/2+beam,0,-35]) y_plate(front = false);
        rotate([0,-90,0]) translate([length/2-beam,0,-35]) y_plate(front = true);
    }
}

if(part == 9){
    projection(){
        translate([beam*3,0,0]) bed_plate();
        translate([-beam*3,0,0]) bed_plate();
    }
}

if(part == 3){
    y_bracket();
}

if(part == 4){
    y_plate();
}

if(part == 5){
    y_plate_bracket(shift = 0);
}

if(part == 6){
    y_plate_bracket(shift = 1);
}

if(part == 7){
    y_gantry();
    translate([0,16,-bracket_thick/2]) groovemount_screw_clamp();
}

if(part == 8){
    y_tensioner();
}

if(part == 100){
    assembled();
}

module assembled(){
    frame();
    
    rods_and_rails();
    
    //corner brackets
    for(i=[0,1]) for(j=[0,1]) mirror([j,0,0]) mirror([0,i,0])
        translate([-length/2-bracket_thick/2,length/2,beam]) mirror([i,0,0]) rotate([0,-90,0]) rotate([0,0,-90]) render() side_bracket(feet=true, corner=true);
    
    spacer_plate_drive();
    spacer_plate_idler();
    
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

module rods_and_rails(solid = 0, z_rollers=true, draw_y_beam = true){
    //x rails
    translate(x_rail_offset_rear+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) linear_rail();
    translate(x_rail_offset_front+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) rotate([0,0,angle]) {
        linear_rail();
        translate([-beam/2,-beam/2-linear_rail_height/2,-(length-beam*2-bracket_thick*2-1)/2]) {
            beam_2040(height = length-beam*2-bracket_thick*2-1);
            //beam screwholes
            for(i=[-beam/2, beam/2]) translate([i,0,-beam*2]) cylinder(r=m5_rad, h=length+beam);
        }
        
    }
    
    //x axis
    translate(x_motor_offset) rotate([0,90,0]) {
        cylinder(r=4, h=length, center=true);
        if(solid != 1) {
            for(i=[0,1]) mirror([0,0,i]) translate([0,0,length/2-beam]) motor_holes();
            
            translate([0,0,bracket_thick]) mirror([0,0,1]) rotate([0,0,90+angle/2]) backlash_nut();           
        }
    }
    
    //y axis   
    translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) {
        if(solid != 1) {
            //y rail
            translate([0,length/2-y_beam_inset,0]) rotate([90,0,0]) linear_rail(solid = solid, beam = draw_y_beam);
            %translate([0,motor_w+37,0]) rotate([0,0,-90]) y_gantry();
            
            translate(y_motor_offset) motor_holes();
        }
    }
    
    //z rollers
    if(z_rollers == true){
        for(i=[roller_offset_rear,roller_offset_front]) translate(i) rotate([90,0,0]) rotate([0,90,0]) {
            cylinder(r=roller_rad, h=roller_len, center=true);
            cylinder(r=roller_rod_rad, h=length, center=true);
        }
    
        //z motor
        z_angle = 25;
        translate(roller_offset_rear+[length/2-beam,0,0])
        rotate([z_angle,0,0]) translate([0,0,distance_between_axles]) rotate([-z_angle,0,0])
        rotate([0,90,0]) motor_holes();
    }
    
    echo("roller sep = ");
    echo(roller_offset_front - roller_offset_rear);
    echo("Belt Length = ");
    echo((roller_offset_front - roller_offset_rear)[1] * 2 + 2*3.14159*roller_rad);
}


//this goes on the end of the Y axis and tensions the belt.
module y_tensioner(length = 37){
    min_rad = wall/2;
    rotate([180,0,0]) 
    difference(){
        union(){
            minkowski(){
                cube([linear_rail_width+wall, linear_rail_height+wall, length+wall], center=true);
                sphere(r=min_rad, $fn=6);
            }
            
            //belt pulley mount
            translate([y_pulley_offset,0,length/2-wall]) rotate([90,0,0]) {
                translate([0,0,linear_rail_height/2]) cylinder(r1=linear_rail_width/2+wall, r2=m5_rad+1, h=wall);
                hull(){
                    cylinder(r=linear_rail_width/2+wall, h=linear_rail_height+wall/2, center=true);
                    cylinder(r=linear_rail_width/2+wall/2, h=linear_rail_height+wall, center=true);
                    
                    translate([-y_pulley_offset,-length+linear_rail_width/2+wall,0]) {
                        cylinder(r=linear_rail_width/2+wall, h=linear_rail_height+wall/2, center=true);
                        cylinder(r=linear_rail_width/2+wall/2, h=linear_rail_height+wall, center=true);
                    }
                }
            }
        }
        
        //rail cutout
        translate([0,0,-wall]) cube([linear_rail_width+slop*4, linear_rail_height+slop*4, length], center=true);
        
        //tensioner
        translate([0,0,length/2+wall]){
            translate([0,0,-wall*2+m5_nut_height+1+.25]) cylinder(r=m5_rad, h=length, center=true);
            
            translate([0,0,-wall*2]){
                cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=m5_nut_height+1, $fn=6);
            
                //place to insert the nut
                hull(){
                    translate([0,0,-length-wall]) cylinder(r=m5_nut_rad+1, h=.1, $fn=6);
                    cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=.1, $fn=6);
                }
            }
        }
        
        //belt nut and shaft
        translate([y_pulley_offset,-linear_rail_height/2+wall*2,length/2-wall]) rotate([90,0,0]){
            cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=m5_nut_height+1, $fn=6);
            
            //place to insert the nut
            hull(){
                translate([0,0,-linear_rail_height-wall]) rotate([0,0,180]) cap_cylinder(r=m5_nut_rad+1, h=.1);
                cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=.1, $fn=6);
            }
            
            //shaft
            cap_cylinder(r=m5_rad, h=50, center=true);
        }
        
        //extra flat bottom
        translate([0,0,50+length/2+wall-1]) cube([100,100,100], center=true);
    }
}

module bed_plate(){
    difference(){
        hull(){
            for(i=[-2:1:2]){
                for(j=[-1,1]){
                    translate([beam*i, beam*j, 0]) cylinder(r=beam/2, h=bracket_thick, center=true);
                }
            }
        }
        
        for(i=[-2:1:2]){
            for(j=[-1,1]){
                translate([beam*i, beam*j, 0]) {
                    cylinder(r=m5_rad-.125, h=bracket_thick+1, center=true);
                    cylinder(r=m5_cap_rad, h=bracket_thick+1);
                }
            }
        }
    }
}

module y_plate_bracket(shift = 1){
    hole_lift = 5;
    
    %render() y_plate();
    %render() rods_and_rails(solid = 0, z_rollers = false);
    translate(x_rail_offset_rear+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) translate([0,14,13]) difference(){
        hull(){
            for(i=[0,1]) mirror([i,0,0]) translate([linear_rail_carriage_screw_sep_w/2,0,0]) rotate([90,0,0]) {
                cylinder(r=wall, h=wall);
                translate([0,-1.5*wall,0]) cylinder(r=wall, h=wall);
            }
                
            for(i=[-1,0,1]) translate([(i+shift)*linear_rail_screw_sep/2,hole_lift,-14]) rotate([0,0,0]) cylinder(r=wall, h=wall);
            
            if(shift == 1){
                translate([.8*linear_rail_carriage_screw_sep_w,0,0]) rotate([90,0,0]) {
                    cylinder(r=wall, h=wall);
                    translate([0,-1.5*wall,0]) cylinder(r=wall, h=wall);
                }
                
                translate([2*linear_rail_screw_sep/2,hole_lift,-14]) rotate([0,0,0]) cylinder(r=wall, h=wall);
            }
        }
        for(i=[0,1]) mirror([i,0,0]) translate([linear_rail_carriage_screw_sep_w/2,0,0]) rotate([-90,0,0]) {
            cylinder(r=m3_rad, h=wall*6, center=true);
            translate([0,0,-.5]) cylinder(r=m3_cap_rad, h=wall*6);
        }
        
        for(i=[-1,0,1]) translate([(i+shift)*linear_rail_screw_sep/2,hole_lift,-14]) rotate([0,0,0]) {
            cylinder(r=m3_rad, h=wall*6, center=true);
            hull(){
                translate([0,0,wall-.5]) cylinder(r=m3_cap_rad, h=wall*6);
                translate([0,wall,wall-.5]) cylinder(r=m3_cap_rad, h=wall*6);
            }
        }
    }
}


module y_plate(front = false){
    rad = 29;
    difference(){
        union(){
            hull(){
                translate(x_rail_offset_rear+[0,5,beam*1.5+linear_rail_height/2+rad]) rotate([0,90,0]) cylinder(r=rad, h=bracket_thick, center=true);
                translate(x_rail_offset_front+[0,0,beam*1.5+linear_rail_height/2]) rotate([angle,0,0]) translate([0,0,rad]) rotate([0,90,0]) cylinder(r=rad, h=bracket_thick, center=true);
                    

                translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_body(extra=bracket_thick, thick=bracket_thick);
                
                translate(extruder_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_body(extra=bracket_thick, thick=bracket_thick);
            }
        }
        
        translate([0,-beam/2+12.5-length,beam*1.5+y_bracket_hole_lift]) rotate([0,0,90]) rotate([0,90,0]) linear_rail(solid = 0, beam = false);
        
        rods_and_rails(solid = 0, z_rollers = false, draw_y_beam = front);
        
        //if(front == true){
            translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_holes();
        
            translate(extruder_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_holes();
        //}else{
            //translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_body(extra=.25, thick=bracket_thick*3);
        
            //translate(extruder_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_body(extra=.25, thick=bracket_thick*3);
        //}
    }
}

module spacer_plate_drive(){
    difference(){
        translate([length/2-beam-bracket_thick/2,0,0])
        hull(){
            translate([0,-length/2,beam*2]) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
            translate(roller_offset_rear) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
            //x motor
            translate(x_motor_offset) rotate([0,90,0]) cylinder(r=motor_r, h=bracket_thick, center=true);
            
            //z motor
            z_angle = 25;
            translate(roller_offset_rear) rotate([z_angle,0,0]) translate([0,0,distance_between_axles]) rotate([-z_angle,0,0]) rotate([0,90,0]) cylinder(r=motor_r, h=bracket_thick, center=true);
            
            //screwhole meat
            translate([0,-length/2+beam*5,beam/2]) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
            translate([0,-length/2+beam,beam/2]) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
        }
        
        rods_and_rails(solid = 0);
        
        //cut out the rear beam
        translate([0,-length/2-beam/2,0]) cube([length, beam, beam*3], center=true);
        
        //mounting holes
        translate([length/2-beam-bracket_thick/2,0,0]) {
            for(i=[1,3,5]) 
                translate([0,-length/2+beam*i,beam]) rotate([0,90,0]) cylinder(r=m5_rad, h=bracket_thick*3, center=true);
            for(i=[2,4]) 
                translate([0,-length/2+beam*i,0]) rotate([0,90,0]) cylinder(r=m5_rad, h=bracket_thick*3, center=true);
        }
    }
}

module spacer_plate_idler(){
    mirror([1,0,0])
    difference(){
        translate([length/2-beam-bracket_thick/2,0,0])
        hull(){
            translate([0,-length/2,beam*2]) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
            translate(roller_offset_rear) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
            //x motor
            translate(x_motor_offset) rotate([0,90,0]) cylinder(r=motor_r/2, h=bracket_thick, center=true);
            
            translate(x_motor_offset+[0,beam*2,beam/3]) rotate([0,90,0]) cylinder(r=motor_r/2, h=bracket_thick, center=true);
            
            //screwhole meat
            translate([0,-length/2+beam*5,beam/2]) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
            translate([0,-length/2+beam,beam/2]) rotate([0,90,0]) cylinder(r=beam, h=bracket_thick, center=true);
        }
        
        rods_and_rails(solid = 0);
        
        //cut out the rear beam
        translate([0,-length/2-beam/2,0]) cube([length, beam, beam*3], center=true);
        
        //mounting holes
        translate([length/2-beam-bracket_thick/2,0,0]) {
            for(i=[1,3,5]) 
                translate([0,-length/2+beam*i,beam]) rotate([0,90,0]) cylinder(r=m5_rad, h=bracket_thick*3, center=true);
            for(i=[2,4]) 
                translate([0,-length/2+beam*i,0]) rotate([0,90,0]) cylinder(r=m5_rad, h=bracket_thick*3, center=true);
        }
    }
}

module y_gantry(){
    //holes are m3, ~5mm deep.
    hole_sep_x = 20;
    hole_sep_y = 20;
    hole_rad = m3_rad;
    hole_cap_rad = m3_cap_rad;
    hotend_extend = 15;
    hotend_y_offset = 14;
    pulley_rad = 6;
    
    difference(){
        union(){
            //body
            hull() for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([hole_sep_x/2, hole_sep_y/2, 0]){
               cylinder(r=hole_rad+wall,h=bracket_thick/2, center=true);
                cylinder(r=hole_rad+wall/2,h=bracket_thick, center=true);
            }
            //belt mount
            mirror([0,0,0]) translate([0,y_pulley_offset+pulley_rad+1,bracket_thick]) hull(){
                cube([hole_sep_x+wall*2,wall,7],center=true);
                translate([0,wall,-bracket_thick]) cube([hole_sep_x+hole_rad*2+wall,wall*4,bracket_thick],center=true);
                translate([0,wall,-bracket_thick*1.25+chamfer]) cube([hole_sep_x+hole_rad*2+wall*2,wall*3,bracket_thick/2],center=true);
                
                translate([0,0,-bracket_thick*1.25+chamfer]) cube([hole_sep_x+hole_rad*2+wall*3,wall*1,bracket_thick/2],center=true);
                
                translate([0,wall,-bracket_thick]) cube([hole_sep_x+hole_rad*2+wall,wall,1],center=true);
            }
            
            //hotend clamp mount
            translate([0,hotend_y_offset,hotend_extend-bracket_thick/2]) mirror([0,1,0]) rotate([-90,0,0]) groovemount_screw(height = hotend_extend);
        }
        
        //gantry attach holes
        for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([hole_sep_x/2, hole_sep_y/2, 0]){
            if(j == 1) cylinder(r1=hole_cap_rad, r2=hole_cap_rad-1.5, h=bracket_thick*3);
            cylinder(r=hole_rad,h=bracket_thick*6, center=true);
        }
        
        //belt grip
        for(i=[1]) translate([0,y_pulley_offset+pulley_rad+1,-.1]){
            difference(){
                translate([0,0,0]) cube([100,2.25,bracket_thick+wall/2],center=true);
                
                for(i=[-19:2:19]) hull(){
                    translate([i,-1,-1]) cube([1,2,8], center=true);
                    translate([i,-1.5,-.5]) cube([1,2,8], center=true);
                }
            }
        }
        
        //zip ties to clamp the belts on
        for(i=[0,1]) mirror([i,0,0]) translate([hole_sep_x/2+3.5,y_pulley_offset+4.5,4.5]) rotate([0,90,0]) rotate_extrude(){
            translate([9,0,0]) square([2,4], center=true);
        }
        
        //hotend clamp holes
        //hotend clamp mount
        translate([0,hotend_y_offset,hotend_extend]) mirror([0,1,0]) rotate([-90,0,0]) groovemount_screw(height = hotend_extend, solid=0, nuts = false);
    }
}

////Standard parts below :-)
module linear_rail(carriage = true, solid = 1, beam = true){
    difference(){
        if(beam == true)
            cube([linear_rail_width, linear_rail_height, length], center=true);
        for(i=[-length/2+linear_rail_screw_offset:linear_rail_screw_sep:length/2]) translate([0,0,i])
            rotate([90,0,0]) cylinder(r=m3_rad, h=linear_rail_carriage_height*3, center=true);
    }
    
    if(solid == 0){
        for(i=[-length/2+linear_rail_screw_offset:linear_rail_screw_sep/2:length/2]) translate([0,0,i])
            rotate([90,0,0]) cylinder(r=m3_rad+.01, h=linear_rail_carriage_height*3, center=true);
    }
    
    if(carriage == true){
        translate([0,linear_rail_carriage_offset,0]) difference(){
            cube([linear_rail_carriage_width, linear_rail_carriage_height, linear_rail_carriage_length], center=true);
            for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,0,j]) translate([linear_rail_carriage_screw_sep_w/2, 0, linear_rail_carriage_screw_sep_l/2]) {
                rotate([90,0,0]) cylinder(r=m3_rad, h=linear_rail_carriage_height*3, center=true);
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

module groovemount_screw(solid=1,e3d=1, height = 19, nuts = true){
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
                translate([0,0,-wall/2+m3_nut_height/2+.5+.3]) rotate([0,0,180]) cap_cylinder(r=m3_rad, h=25);
                translate([0,0,-28+-wall/2+m3_nut_height/2+.5+.3]) rotate([0,0,180]) cap_cylinder(r=m3_rad, h=25);
                
                //nuts
                if(nuts == true){
                    translate([0,0,-wall/2]) rotate([0,0,45]) cylinder(r2=m3_sq_nut_rad, r1=m3_sq_nut_rad+.5, h=m3_nut_height+1, center=true, $fn=4);
                    hull(){
                        translate([0,-m3_sq_nut_rad*.8,-wall/2]) rotate([0,0,45]) cylinder(r2=m3_sq_nut_rad, r1=m3_sq_nut_rad+.5, h=m3_nut_height+1, center=true, $fn=4);
                        translate([0,-m3_sq_nut_rad*2,-wall/2]) rotate([0,0,45]) cylinder(r2=m3_sq_nut_rad+.25, r1=m3_sq_nut_rad+.75, h=m3_nut_height+1, center=true, $fn=4);
                    }
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