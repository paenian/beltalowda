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
roller_inside_rad = 2.075/2*in-.075;

//roller bearings - 10mm rods right now.
bearing_rad = 26/2+.15;
//bearing_rad = 32/2+.125;    //switch everything to 12mm rods?  Or keep the rollers on 10mm?
bearing_thick = 8;
bearing_inset = in;

//roller drive variables
small_teeth = 13;
motor_shaft_rad = 5/2+.2;
big_teeth = 61;
gear_thick = 13;
distance_between_axles = 37;
circular_pitch = 360*distance_between_axles/(small_teeth+big_teeth);

//bracket variables
bracket_thick = 6;
chamfer = 1.5;

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
y_bracket_hole_lift = linear_rail_carriage_height+14.5;

bed_height = roller_rad+roller_rod_rad+3;
bed_height = beam*2;
bed_offset_rear = -89;

extruder_offset = y_beam_offset - [0,motor_w*1.5,motor_w/2];

part = 21;

if(part == 1){
    projection(){
        rotate([0,90,0]) translate([-length/2+beam,0,beam/2+.1]) spacer_plate_drive();
        rotate([0,-90,0]) translate([length/2-beam,0,beam/2+.1]) spacer_plate_drive();
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
        translate([beam*3.1,0,0]) bed_plate();
        translate([-beam*3.1,0,0]) bed_plate();
    }
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

if(part == 77){
    translate([0,16,-bracket_thick/2]) groovemount_clamp_fan();
}

if(part == 8){
    y_tensioner();
}

if(part == 10){
    bed_clamp();
}

if(part == 11){
    bed_rear_support();
}

if(part == 12){
    bed_front_support();
}

if(part == 20){
    mirror([0,0,1]) roller_drive_mount();
}

if(part == 21){
   mirror([0,0,1]) motor_drive_gear();
}

if(part == 22){
    mirror([0,0,1]) roller_mount();
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
            for(i=[0,1]) mirror([0,0,i]) translate([0,0,length/2-beam]) motor_holes(slot=0);
            
            translate([0,0,bracket_thick]) mirror([0,0,1]) rotate([0,0,90+angle/2]) backlash_nut();           
        }
    }
    
    //y axis   
    translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) {
        if(solid != 1) {
            //y rail
            translate([0,length/2-y_beam_inset,0]) rotate([90,0,0]) linear_rail(solid = solid, beam = draw_y_beam);
            %translate([0,motor_w+37,0]) rotate([0,0,-90]) y_gantry();
            
            translate(y_motor_offset) motor_holes(slot=0);
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
        rotate([0,90,0]) motor_holes(slot=0);
    }
    
    echo("roller sep = ");
    echo(roller_offset_front - roller_offset_rear);
    echo("Belt Length = ");
    echo((roller_offset_front - roller_offset_rear)[1] * 2 + 2*3.14159*roller_rad);
}


module motor_drive_gear(){
    translate([distance_between_axles+1,0,0]) gear1(gear1_teeth = small_teeth, circular_pitch=circular_pitch, gear_height=gear_thick);
}

module roller_drive_mount(wall = 3){
    %motor_drive_gear();
    
    radius = gear_radius(big_teeth, circular_pitch);
    outer_radius = gear_outer_radius(big_teeth, circular_pitch);
    
    gear_chamfer_radius = (outer_radius - radius) / tan(45);
    
    lift = gear_thick+1;
    
    difference(){
        union(){
            
            //roller mount
            translate([0,0,lift-.05]) roller_mount();
            //gear
            chamfered_herring_gear(height=gear_thick, number_of_teeth=big_teeth, circular_pitch=circular_pitch, teeth_twist=-1);
            //connect the two
            translate([0,0,gear_thick-.05]) cylinder(r1=radius, r2=roller_inside_rad+wall, h=lift-gear_thick+.1);
        }
        
        //hollow out a path upwards
        translate([0,0,-.1]) cylinder(r1=bearing_rad+wall*3, r2=bearing_rad+wall*2, h=lift+1);
        
        //reopen the tightener holes for the set screws
        translate([0,0,lift-.05]) for(i=[60:360/3:359]) rotate([0,0,i]) translate([0,0,wall*3]) {            
            //access hole
            rotate([0,0,0]) rotate([0,-90-13,0]) rotate([0,0,-90]) cap_cylinder(r=m5_rad+.5, h=50);
        }
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
        
        //three set screws to lock the roller in place
        for(i=[60:360/3:359]) rotate([0,0,i]) translate([0,0,wall*3]) {
            //screw
            rotate([0,90,0]) rotate([0,0,90]) cap_cylinder(r=m5_rad, h=50);
            
            //nut
            rotate([0,90,0]) translate([0,0,roller_inside_rad-m5_nut_height]) cylinder(r=m5_sq_nut_rad, h=15, $fn=4);
            
            //access hole
            rotate([0,0,0]) rotate([0,-90-13,0]) rotate([0,0,-90]) cap_cylinder(r=m5_rad+.5, h=50);
        }
        
        //approach the bearing
        translate([0,0,-.1]) cylinder(r1=bearing_rad+wall*2, r2=bearing_rad+wall, h=bearing_inset-bearing_thick+.2);
        //mount the bearing
        translate([0,0,-.1]) cylinder(r2=bearing_rad, r1=bearing_rad+slop/2, h=bearing_inset+.1);
        //center through hole
        translate([0,0,-.1]) cylinder(r=bearing_rad-wall, h=bearing_inset+.2+wall);
        
        //hold the bearing in place
        for(i=[0:360/2:359]) rotate([0,0,i]) translate([bearing_rad+m3_rad+.6,0,0]) {
            cylinder(r=m3_rad, h=bearing_inset+.2+wall);
            cylinder(r=m3_cap_rad+1, h=bearing_inset-bearing_thick+.2);
        }
    }
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
            for(i=[-3:1:2]){
                for(j=[-1,1]){
                    translate([beam*i, beam*j, 0]) cylinder(r=beam/2, h=bracket_thick, center=true);
                }
            }
        }
        
        for(i=[-3:1:2]){
            for(j=[-1,1]){
                translate([beam*i, beam*j, 0]) {
                    cylinder(r=m5_rad-.125, h=bracket_thick+1, center=true);
                    cylinder(r=m5_cap_rad, h=bracket_thick+1);
                }
            }
        }
    }
}

module bed_clamp(){
    difference(){
        union(){
            //mounting lugs
            hull() for(i=[-beam, 0, beam*1]) translate([i,-beam/2,0]) {
                cylinder(r=m5_cap_rad+wall-1, h=bracket_thick, center=true);
                cylinder(r=m5_cap_rad+wall, h=bracket_thick/2, center=true);
                translate([0,beam,0]) cylinder(r=m5_cap_rad+wall, h=bracket_thick, center=true);
            }
            
            //bed seat
            //translate([0,0,]) cube([beam*3,15,bed_lift], center=true);
        }
        
        //screwholes
        for(i=[-beam, 0, beam]) translate([i,-beam/2,0]){
            cylinder(r=m5_rad, h=bracket_thick+1, center=true);
            cylinder(r=m5_washer_rad+.25, h=bracket_thick);
            translate([0,0,bracket_thick/2-1]) cylinder(r1=m5_washer_rad+.25, r2=m5_washer_rad+1, h=1.1);
        }
        
        //bed seat
        translate([0,beam,bed_lift]) cube([beam*3.25,beam*2,bracket_thick], center=true);
    }
}

module bed_front_support(){
    difference(){
        union(){
            //mounting lugs
            hull() for(i=[-beam*3, 0, beam*3]) translate([i,-beam/2,0]) {
                cylinder(r=m5_cap_rad+wall-.5, h=bed_lift, center=true);
                cylinder(r=m5_cap_rad+wall, h=bed_lift-1, center=true);
            }
            
            //line it up with the t-slot
            hull() for(i=[-beam*3, 0, beam*3]) translate([i,-beam/2,bed_lift/2]) {
                cylinder(r=3, h=2.75, center=true);
            }
        }
        
        //screwholes
        for(i=[-beam*2, 0, beam*2]) translate([i,-beam/2,0]){
            cylinder(r=m3_rad, h=bracket_thick+1, center=true);
        }
    }
}

module bed_rear_support(){
    slot = 2;
    difference(){
        union(){
            //mounting lugs
            hull() for(i=[-beam, 0, beam*1]) translate([i,-beam/2-slot,0]) {
                cylinder(r=m5_cap_rad+wall-1, h=bracket_thick, center=true);
                cylinder(r=m5_cap_rad+wall, h=bracket_thick/2, center=true);
                translate([0,beam/2+slot-m5_cap_rad-wall+bed_lift,0]) cylinder(r=m5_cap_rad+wall, h=bracket_thick, center=true);
            }
        }
        
        //screwholes
        for(i=[-beam, 0, beam]) translate([i,-beam/2,0]){
            hull(){
                cylinder(r=m5_rad, h=bracket_thick+1, center=true);
                translate([0,-slot,0]) cylinder(r=m5_rad, h=bracket_thick+1, center=true);
            }
            hull(){
                cylinder(r=m5_washer_rad+.25, h=bracket_thick);
                translate([0,-slot,0]) cylinder(r=m5_washer_rad+.25, h=bracket_thick);
            }
            hull(){
                translate([0,0,bracket_thick/2-1]) cylinder(r1=m5_washer_rad+.25, r2=m5_washer_rad+1, h=1.1);
                translate([0,-slot,0]) translate([0,0,bracket_thick/2-1]) cylinder(r1=m5_washer_rad+.25, r2=m5_washer_rad+1, h=1.1);
            }
        }
    }
}

module y_plate_bracket(shift = 1){
    hole_lift = 6.5;
    
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
                translate(x_rail_offset_rear+[0,5,beam*1.5+linear_rail_height/2+rad]) rotate([0,90,0]) cylinder(r=rad, h999999=bracket_thick, center=true);
                translate(x_rail_offset_front+[0,0,beam*1.5+linear_rail_height/2]) rotate([angle,0,0]) translate([0,0,rad]) rotate([0,90,0]) cylinder(r=rad, h=bracket_thick, center=true);
                    

                translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_body(extra=bracket_thick, thick=bracket_thick);
                
                translate(extruder_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_body(extra=bracket_thick, thick=bracket_thick);
            }
        }
        
        //rear attachment to x rail
        #translate([0,-beam/2+12.5-length,beam*1.5+y_bracket_hole_lift]) rotate([0,0,90]) rotate([0,90,0]) linear_rail(solid = 0, beam = false);        
        
        rods_and_rails(solid = 0, z_rollers = false, draw_y_beam = front);
        
        //if(front == true){
            translate(y_beam_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_holes(slot=0);
        
            translate(extruder_offset) rotate([0,90,0]) rotate([0,0,angle]) translate(y_motor_offset) motor_holes(slot=0);
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
            #rotate([90,0,0]) cylinder(r=m3_rad+.01, h=linear_rail_carriage_height*3, center=true);
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
                    translate([0,0,2]) cylinder(r=screw_mount_rad, h=height+4, center=true);
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


module groovemount_clamp_fan(){
    groove_lift = 5;
    wall = 3;
    dia = 16;
    rad = dia/2+slop;
    mink = 1;
    inset = 3;
    groove = 9+2;
    thick = rad-2+groove_lift;
    length = 10;
    
    hs_rad = 23/2;
    hs_height = 26;
    hotend_inset = [0,0,rad+groove_lift];
    hotend_height = 63;
    
    cooling_fan_offset = 37;
    
    
    fan_screw_sep = 24;
    fan_screw_rad = 3/2+slop;
    fan_corner_rad = 3.25;
    fan_rad = 27/2;
    fan_width = fan_screw_sep+fan_corner_rad*2;
    
    difference(){
        union(){
            //screwhole mounts
            hull() for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,0]) cylinder(r1=screw_mount_rad+.5, r2=screw_mount_rad, h=thick);
                
            //extruder fan mount
            translate([0,hs_height+1,0]){
                 hull() for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([fan_screw_sep/2, fan_screw_sep/2, 0])
                    cylinder(r=fan_corner_rad, h=thick);
            
                translate(hotend_inset) rotate([90,0,0]) cylinder(r=hs_rad+wall, h=fan_screw_sep, center=true);
            }
            
            //cooling fan mount
            translate([27,hs_height+1,fan_screw_sep/2+fan_corner_rad-.5]) rotate([0,90,0]) rotate([70,0,0]) {
                hull() for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([fan_screw_sep/2, fan_screw_sep/2, 0])
                    cylinder(r=fan_corner_rad, h=thick/2);
            }
            
            //cooling fan duct
            hull(){
                translate([27,hs_height+1,fan_screw_sep/2+fan_corner_rad-.5]) rotate([0,90,0]) rotate([70,0,0]) 
                    cylinder(r=fan_rad+wall, h=thick/2);
                translate([cooling_fan_offset,hs_height*1.5,fan_rad/2+wall/2-.5]) cylinder(r=fan_rad/2+wall, h=fan_rad+wall, center=true);
            }
            hull(){
                translate([cooling_fan_offset,hs_height*1.5,fan_rad/2+wall/2-.5]) cylinder(r=fan_rad/2+wall, h=fan_rad+wall, center=true);
                translate([cooling_fan_offset-11,hs_height*2+4,rad+groove_lift]) cylinder(r=fan_rad/4+wall, h=fan_rad/2+wall*2, center=true);
            }
        }
        
        //screwholes
        for(i=[0,1]) mirror([i,0,0]) translate([screw_mount_screw_sep/2,7,-.1]) {
            cylinder(r1=4.25, r2=3.75, h=groove_lift);
            translate([0,0,groove_lift+.2]) cylinder(r=m3_rad+slop, h=rad);
        }
        
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
       
       //extruder fan duct
        translate([0,hs_height+1,0]) {
            translate(hotend_inset) translate([0,wall,0]) rotate([90,0,0]) cylinder(r=hs_rad, h=fan_screw_sep+fan_corner_rad+wall*2, center=true);
            hull() {
                //actual heatsink
                #translate(hotend_inset) rotate([90,0,0]) cylinder(r=hs_rad, h=fan_screw_sep+fan_corner_rad, center=true);
                
                for(i=[-rad-groove_lift]) translate([0,0,i]) translate(hotend_inset) cylinder(r=fan_rad, h=.1, center=true);
            }
            
            //nozzle indicator
            #translate(hotend_inset+[0,5,0]) rotate([90,0,0]) cylinder(r=.1, h=hotend_height, center=true);
            
            for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([fan_screw_sep/2, fan_screw_sep/2, 0])
                cylinder(r=fan_screw_rad, h=thick*7, center=true);
        }
        
        //cooling fan mount
        translate([27,hs_height+1,fan_screw_sep/2+fan_corner_rad-.5]) rotate([0,90,0]) rotate([70,0,0]) {
            for(i=[0,1]) for(j=[0,1]) mirror([i,0,0]) mirror([0,j,0]) translate([fan_screw_sep/2, fan_screw_sep/2, 0])
                cylinder(r=fan_screw_rad, h=thick*3, center=true);
        }
            
        //cooling fan duct
        hull(){
            translate([27,hs_height+1,fan_screw_sep/2+fan_corner_rad-.5]) rotate([0,90,0]) rotate([70,0,0]) 
                cylinder(r=fan_rad, h=thick/2+.2);
            translate([cooling_fan_offset,hs_height*1.5,fan_rad/2+wall/2-.5]) cylinder(r=fan_rad/2, h=fan_rad, center=true);
        }
        hull(){
            translate([cooling_fan_offset,hs_height*1.5,fan_rad/2+wall/2-.5]) cylinder(r=fan_rad/2, h=fan_rad, center=true);
            translate([cooling_fan_offset-11,hs_height*2+3,rad+groove_lift]) cylinder(r=fan_rad/4, h=fan_rad/2+wall, center=true);
        }
        hull(){ //let the air out :-)
            #translate([cooling_fan_offset-11,hs_height*2+3,rad+groove_lift]) cylinder(r=fan_rad/4, h=fan_rad/2+wall, center=true);
            #translate([cooling_fan_offset-11-10,hs_height*2+3+2.5,rad+groove_lift]) cylinder(r=fan_rad/4, h=fan_rad/2+wall, center=true);
        }
       
       
       //slice off the bottom and the top
       translate([0,0,-100]) cube([200,200,200], center=true);
       translate([0,0,100+rad*2.25]) cube([hs_rad*2+wall*1.5,200,200], center=true);
        #translate([0,100+hotend_height-1,0]) cube([200,200,200], center=true);
    }
}
