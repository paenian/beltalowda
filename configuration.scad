in = 25.4;
mdf_wall = 6.5;
mdf_tab = 15;

wall = 5;

screw_slop = .2;
slop = .2;
laser_slop = -.1;

beam = 20;

layer_height=.2;

pulley_rad = 13/2;
pulley_flange_rad = 18/2;

//bed thicknesses
bed_inset = 4;
bed_thick = 2.3;
heater_thick = 2.2;
insulation_thick = .1;
bed_lift = heater_thick+insulation_thick;

eccentric_rad = 7.3/2;
eccentric_flange_rad = 11/2;

belt_thick = 9;
belt_width = 1.5;

//belt drive variables
small_teeth = 13;
motor_shaft_rad = 5/2+.2;
big_teeth = 41;
gear_thick = 13;
distance_between_axles = 37;
circular_pitch = 360*distance_between_axles/(small_teeth+big_teeth);


//motor size and placement variables
motor_w = 42;
motor_r = 52/2;
motor_screw_sep = 31;

//standard screw variables
m3_nut_rad = 6.01/2+slop;
m3_nut_height = 2.4;
m3_rad = 3.1/2+slop;
m3_cap_rad = 3.5;
m3_cap_height = 2;
m3_sq_nut_rad = 7.9/2;

m4_nut_rad = 7.66/2+slop;
m4_nut_height = 3.2;
m4_rad = 4/2+slop;
m4_cap_rad = 7/2+slop;
m4_cap_height = 2.5;

m5_nut_rad = 8.79/2;
m5_sq_nut_rad = (8*sqrt(2)+slop/2)/2;
m5_nut_rad_laser = 8.79/2-.445;
m5_nut_height = 4.7;
m5_rad = 5/2+slop;
m5_rad_laser = 5/2-.1;
m5_cap_rad = 10/2+slop;
m5_cap_height = 3;
m5_washer_rad = 11/2+slop;

ten24_rad = (.19*in/2+slop);
ten24_cap_rad = (.361*in/2+slop);
ten24_cap_height = .101*in+slop;
ten24_nut_rad = ((3/8*in)*cos(180/6))/2;
ten24_sq_nut_rad = ((3/8*in)*sqrt(2))/2+slop/2;

ten24_nut_height = 1/8*in+slop;

ten24_rad_laser = ten24_rad+laser_slop/2;
ten24_sq_nut_rad_laser = ten24_sq_nut_rad+laser_slop/2;
ten24_sq_nut_flat = 9.5;
ten24_sq_nut_flat_laser = ten24_sq_nut_flat+laser_slop;

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


//makes all the holes have lots of segments
$fs=.5;
$fa=.1;


//machine configuration parameters
y_rail_sep = 300;
