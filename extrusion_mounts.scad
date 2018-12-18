include <configuration.scad>

//%extrusion();

$fn=72;

part = 3;

if(part == 1){
    rotate([0,90,0]) rod_mount(rod_rad = 5.25, extrusion=true);
}

if(part == 2){
    tensioner();
}

if(part == 3){
    projection() spacer();
}

//exit_ramp();


ball_rad = 15/2;
rod_rad = 4.25;
screw_rad = 1.8;
nut_rad = 6.25/2;
wall = 3;
roller_rad = 43/2+1;

slot_width = 1;

$fn=36;

module spacer(){
    difference(){
        cylinder(r=beam/2/cos(180/8), h=wall, $fn=8);
        cylinder(r=m3_rad, h=wall*5, center=true);
    }
}

module t_nut_m5(){
    length = 17;
    m5_nut_rad = 9.25/2;
    m5_rad = 5.3/2;
    m5_height = 4;
    difference(){
        union(){
            intersection(){
                translate([0,0,-length/2]) rotate([0,0,-135]) cube([20,20,length]);
                translate([-25,-5,-length/2]) rotate([0,0,-90]) cube([7,50,length]);
            }
        }
        
        extrusion(slop = 1);
        
        //m5 nut
        translate([0,-5,0]) rotate([90,0,0]) rotate([0,0,30])  {
            cylinder(r1=m5_nut_rad+.25, r2=m5_nut_rad, h=4, $fn=6);
            cylinder(r=m5_rad, h=30, center=true);
        }
    }
}

//part that slots into the extrusion and guides parts off the bed
module exit_ramp(height = 19, length=33, roller_offset = 51){
    rotate([90,0,0]) difference(){
        hull(){
            intersection(){
                translate([0,0,-length/2]) rotate([0,0,-135]) cube([20,20,length]);
                translate([-25,-5,-length/2]) rotate([0,0,-90]) cube([20,50,length]);
            }
            translate([roller_offset-5,-5-in/2-height,-length/2]) rotate([0,0,45]) cube([10,10,length]);
        }
        extrusion(slop = 1);
       
        //roller 
        hull(){
            translate([roller_offset,-in/2-rod_rad,0]) cylinder(r=roller_rad, h=length*3, center=true);
            translate([roller_offset-10,-in/2-rod_rad+20,0]) cylinder(r=roller_rad, h=length*3, center=true);
        }
    }
}

//this mounts the print cooling fan onto the hotend cooling fan - friction-adjust the fan angle.
module fan_mount(){
    screw_sep = 24;
    cooling_fan_w = 15.25;
    fan_lift = wall*2.5;
    
    difference(){
        union(){
            //offset lugs
            for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,-wall]) hull(){
                cylinder(r=screw_rad+wall, h=wall+.1, $fn=6);
                 translate([0,0,wall]) cylinder(r=screw_rad+wall/2, h=wall, $fn=6);
            }
            //fan bar & mount
            hull() for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,0]){
                cylinder(r=screw_rad+wall/2, h=wall, $fn=6);
                
                
                translate([-wall,0,fan_lift]) rotate([0,90,0]) cylinder(r=screw_rad+wall, h=wall, $fn=6);
            }
        }
        
        for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,-.1]){
            cylinder(r=screw_rad, h=wall*5, center=true);
            translate([0,0,.3]) cylinder(r=nut_rad, h=wall*5);
            
            translate([-wall,0,fan_lift]) rotate([0,90,0]) cylinder(r=nut_rad, h=wall*3, $fn=6);
        }
        
        //fan
        translate([0,0,wall+24.5]) cube([cooling_fan_w, 50,50], center=true);
        
        //fan screw
        translate([0,0,fan_lift]) rotate([0,90,0]) cylinder(r=screw_rad, h=50, center=true);
    }
}


module tensioner(){
    width = 17;
    screw_rad = 4.9/2;
    height = 17;
    
    gnurled_base_rad = 9.5/2;
    gnurled_cap_rad = 9.5/2;
    
    
    difference(){
        union(){
            hull(){
                translate([0,0,wall]) for(i=[0,1]) mirror([i,0,0]) translate([width/2,0,0]) hull(){
                    cylinder(r=beam/2, h=wall, center=true);
                    cylinder(r=beam/2-wall/2, h=wall*2, center=true);
                }
                
                translate([0,-beam/2+wall,height]) rotate([90,0,0])
                    cylinder(r=screw_rad+wall, h=wall*2, center=true);
            }
            
            //gnurled nut platen
            translate([0,-beam/2+wall*1.5,height]) rotate([90,0,0])
                cylinder(r2=screw_rad+wall, r1=gnurled_base_rad, h=wall*3, center=true);
        }
        
        //base screwholes
        for(i=[0,1]) mirror([i,0,0]) translate([width/2,0,0]) {
            cylinder(r=m5_rad, h=wall*11, center=true);
            translate([0,0,wall]) cylinder(r=m5_cap_rad, h=wall*7);
        }
        
        //gnurled nut platen
        translate([0,-beam/2+wall*4.5,height]) rotate([90,0,0]){
            cylinder(r1=gnurled_cap_rad+wall, r2=gnurled_cap_rad, h=wall*3, center=true);
            rotate([0,0,90]) cap_cylinder(r=screw_rad, h=50, center=true);
        }
        
        //cut off the sides
        for(i=[0,1]) mirror([i,0,0]) translate([width/2+50+m5_cap_rad+wall/2,0,0]) {
            cube([100,100,100], center=true);
        }
    }
}

module rod_mount(extrusion=false, width=30){
    screw_sep = 15;
    beam = 20;
    difference(){
        union(){
            //rod mount
            hull() {
                translate([0,0,rod_rad]) rotate([90,0,0]) {
                    cylinder(r=rod_rad+wall, h=beam, center=true);
                    cylinder(r=rod_rad+wall-.5, h=beam+wall, center=true);
                }
                
                if(extrusion == true)
                    translate([0,0,-rod_rad/2+4]) rotate([0,90,0]) {
                    cylinder(r=10, h=screw_sep+screw_rad*6, center=true);
                }
            }
            
            //screwholes
            hull(){
                for(i=[0,1]) mirror([i,0,0]) translate([screw_sep/2,0,0]){
                    cylinder(r=screw_rad+wall, h=wall*3-1);
                    cylinder(r=screw_rad+wall-.5, h=wall*3);
                }
            }
        }
        
        if(extrusion == true){
            translate([0,0,-in/2]) rotate([0,90,0]) extrusion(slop = 1.5);
        }else{
            translate([0,0,-in/2]) cube([in*5,in*5,in], center=true);
        }
        
        //screwholes
        for(i=[-1,1]) mirror([1,0,0]) translate([i*screw_sep/2,0,wall*2.75]){
            cap_cylinder(r=screw_rad*2, h=wall*2, $fn=36, center=false);
            cap_cylinder(r=screw_rad-.3, h=in*2, center=true);
        }
        
        //rod
        if(extrusion == true){
            translate([0,0,rod_rad]) rotate([90,0,0]) rotate([0,0,180]) cap_cylinder(r=rod_rad, h=in*2, center=true);
        }else{
            translate([0,0,rod_rad]) rotate([90,0,0]) rotate([0,0,90]) cap_cylinder(r=rod_rad, h=in*2, center=true);
        }
        
        //smooth the top and bottom
        *for(i=[0,1]) mirror([i,0,0]) translate([50+screw_sep/2+wall*2.75/2,0,0]) cube([100,100,100], center=true);
    }
}

module spring_mount(height=7){
    rotate([90,0,0]) difference(){
        union(){
            intersection(){
                rotate([90,0,0]) hull() {
                    cylinder(r=slot_width/2,h=height/2+in/2);
                    cylinder(r=slot_width*.333,h=height+in/2);
                }
                translate([0,0,-25]) rotate([0,0,-135]) cube([50,50,50]);
                translate([-25,-5,-25]) rotate([0,0,-90]) cube([50,50,50]);
            }
        }
        extrusion(slop = 1);
        rotate([90,0,0]) cylinder(r1=screw_rad-.375, r2=screw_rad-.125, h=height+in/2+.1); 
    }
}

module extrusion_lug(length = in){
    slot_width = in*9/16;
    difference(){
        union(){
            hull(){
                //slot tab
                intersection(){
                    translate([in/2,0,0]) cube([in*3/4, slot_width, length], center=true);
                    translate([in/2*sqrt(2),0,0]) rotate([0,0,45]) cube([in, in, length], center=true);
                }
            }
        }
        extrusion(slop = .5);
    }
}


module extrusion(length = in*3, slop = .1, $fn=16){
    side = 20;
    center_cube = 7.32+slop;
    inner_wall = 1.5+slop;
    slot = 5.26+slop;
    center_rad = 4.2/2+slop;
    difference(){
        union(){
            //center cube
            cube([center_cube, center_cube, length], center=true);
            
            //four corners
            for(i=[0:90:359]) rotate([0,0,i]) {
                //inner walls
                hull(){
                    translate([side/2-inner_wall/2+slop/2,side/2-inner_wall/2+slop/2,0]) cylinder(r=inner_wall/2, h=length, center=true);
                    cylinder(r=inner_wall/2, h=length, center=true);
                }
                
                //corners
                translate([side/2-inner_wall*1.5+slop/2,side/2-inner_wall*1.5+slop/2,0]) cube([inner_wall+.1,inner_wall+.1,length], center=true);
                
                //corner sides
                hull(){
                    translate([side/2-inner_wall/2+slop/2,side/2-inner_wall/2+slop/2,0]) cylinder(r=inner_wall/2, h=length, center=true);
                    translate([side/2-inner_wall/2+slop/2,slot/2+inner_wall/2-slop/2,0]) cylinder(r=inner_wall/2, h=length, center=true);
                }
                hull(){
                    translate([side/2-inner_wall/2+slop/2,side/2-inner_wall/2+slop/2,0]) cylinder(r=inner_wall/2, h=length, center=true);
                    translate([slot/2+inner_wall/2-slop/2,side/2-inner_wall/2+slop/2,0]) cylinder(r=inner_wall/2, h=length, center=true);
                }
            }
        }
        
        //center hole
        cylinder(r=center_rad, h=length+.1, center=true);
    }
}

//A cylinder with a flat on it - used for printing overhangs, mainly.
//
//When printing an axle, put the flat spot downwards - it'll make the bottom much cleaner.
//When printing an axle hole, put the flat spot upwards - it'll make the ceiling cleaner.
module cap_cylinder(r = 3, h=5, center=true, outside=true, r_slop=0){
    difference(){
        hull(){
            cylinder(r=r-r_slop, h=h, center=center);
        
            if(outside == true){
                intersection(){
                    translate([r/2,0,0]) cube([r,r,h], center=true);
                    cylinder(r=(r-r_slop)/cos(180/4), h=h, center=center, $fn=4);
                }
            }
        }
        
        //this makes it into a D-shaft, basically.
        if(outside == false){
            translate([r,0,0]) cube([r/6,r,h+1], center=center);
        }
    }
}