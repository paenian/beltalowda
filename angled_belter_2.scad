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

//extruder variables
screw_mount_rad = 5;
screw_mount_screw_sep = 20;


//positioning variables
x_rail_offset_rear = [0,-length/2-beam/2,0];
x_rail_offset_front = x_rail_offset_rear + [0,93,beam/2];

roller_offset_rear = x_rail_offset_front+[0,roller_rad+19,0];
roller_offset_front = roller_rad+27;

x_motor_offset = x_rail_offset_rear+[0,motor_w/2+linear_rail_width+wall,beam*1.5+motor_w/2];

y_motor_offset = x_motor_offset + [0,motor_w/2, motor_w/2];
y_beam_offset = [0,-motor_w/2,0];




motor_offset = -motor_w/2-x_bearing_rad-wall-13;
motor_rear_offset = -29;

carriage_height = 4.5;

front_beam_offset = y_beam_offset + [linear_rail_width/2+linear_rail_height/2+carriage_height,motor_w/2,0];




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
    for(i=[0:6]) translate([-length/2,bed_offset_rear,bed_height+beam]) rotate([90,0,0]) rotate([0,90,0]) render() beam_2040(height = length, v=false);
}

module rods_and_rails(solid = 0){
    //z rollers
    for(i=[roller_offset_rear,roller_offset_front]) translate(i+[0,0,beam*1.5+roller_rod_rad]) rotate([90,0,0]) rotate([0,90,0]) {
        if(solid == 1){
            cylinder(r=roller_rad, h=roller_len, center=true);
            cylinder(r=roller_rod_rad, h=length, center=true);
        }else{
            cylinder(r=roller_rad, h=roller_len, center=true);
            cylinder(r=roller_rod_rad, h=length, center=true);
            for(i=[0,1]) mirror([0,0,i]) translate([0,0,length/2-beam]) rotate([0,0,-90]) rod_clamp(rad=roller_rod_rad+laser_slop, solid=0);
        }
    }
    
    //x rails
    translate(x_rail_offset_rear+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) linear_rail();
    translate(x_rail_offset_front+[0,0,beam*1.5+linear_rail_height/2]) rotate([0,90,0]) rotate([0,0,90]) rotate([0,0,angle]) linear_rail();
    
    //x motor
    translate(x_motor_offset) rotate([0,90,0]) {
        cylinder(r=4, h=length, center=true);
        if(solid != 1)
            for(i=[0,1]) mirror([0,0,i]) translate([0,0,length/2-beam]) motor_holes();
    }
    
    //y motor
    translate(y_motor_offset) rotate([0,90,0]) rotate([0,0,angle]) {
        if(solid != 1) {
            motor_holes();
            
            //y rail
            translate([0,motor_w/2+length/2,0]) rotate([90,0,0]) linear_rail();
        }
    }
}

module linear_rail(carriage = true){
    cube([linear_rail_width, linear_rail_height, length], center=true);
    translate([0,linear_rail_carriage_offset,0]) cube([linear_rail_carriage_width, linear_rail_carriage_height, linear_rail_carriage_length], center=true);
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