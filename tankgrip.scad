include <bezier_v2.scad>

//pad params
p_length = 220;
p_width = 110;
p_x_offset = -100;
p_y_offset = -50;
p_thick = 1.5;

$fn = 32;

render_part="sides"; //center,sides

// texture params
nub_x = 6.25;
nub_y = 3.6;
nub_z = 1.2;
nub_rx = 0.3;
nub_ry = 1.5;
nub_spacing = 1.5;
nub_concavity = 0.3;

// Calculate the angle using atan2
angle = atan2(nub_y, nub_x);

// Calculate the hypotenuse
hypotenuse = sqrt((nub_x/2)^2 + (nub_y/2)^2);

// Calculate the spacing using trigonometric functions
x_spacing = hypotenuse * cos(angle)+nub_x;
y_spacing = hypotenuse * sin(angle)+nub_y;

echo(x_spacing);
echo(y_spacing);

// define the 2d shape of the pad

module padshape_sides(){
    difference(){
        bezier_polygon([
            // 0
            [[  20,   50], // point N
            [  150, 20], // control N -> N+1
            [130, -50],// control N+1 -> N
            [80,   -50]], // point N+1
            // 1
            [[  80,   -50], // point N
            [  80, -50], // control N -> N+1
            [-80, -50], // control N+1 -> N
            [-80,   -50]], // point N+1
            // 2
            [[-80,   -50], // point N
            [-100,  -50],// control N -> N+1
            [  -100,  -40],// control N+1 -> N
            [  -100,  -30]],// point N+1
            // 3
            [[-100,   -30], // point N
            [-100, 10], // control N -> N+1
            [-70, 65], // control N+1 -> N
            [20,   50]] // point N+1        
            // 0
			],0); // control handle visibility
            
        union(){
            translate([0,-8])rotate([0,0,-96]){
                for(j=[0:1:1]){
                    mirror([j,0])for(i=[-60:35:90]){
                        translate([20,i])rotate([0,0,10])
                            minkowski(){
                                square([80,8]);
                                circle(2);
                            }
                    }
                }
            }
            
        }
        
    }
}

module padshape_center(){
    difference(){
        bezier_polygon([
            // 0
            [[  60,   100], // point N
            [  180, 120], // control N -> N+1
            [50, 70], // control N+1 -> N
            [50,   -20]], // point N+1
            // 1
            [[  50,   -20], // point N
            [  50, -70], // control N -> N+1
            [60, -100], // control N+1 -> N
            [40,   -100]], // point N+1
            // 2
            [[40,   -100], // point N
            [40,  -100],// control N -> N+1
            [  -40,  -100],// control N+1 -> N
            [  -40,  -100]],// point N+1
            // 3
            [[-40,   -100], // point N
            [-60, -100], // control N -> N+1
            [  -50, -70], // control N+1 -> N
            [  -50,   -20]], // point N+1
            // 4
            [[-50,   -20], // point N
            [-50, 70], // control N -> N+1
            [  -180, 120], // control N+1 -> N
            [  -60,   100]], // point N+1
            // 5    
            [[  -60,   100], // point N
            [  -60, 100], // control N -> N+1
            [60, 100], // control N+1 -> N
            [60,   100]] // point N+1        
            // 0
			],0); // control handle visibility
            
        union(){
            for(j=[0:1:1]){
                mirror([j,0])for(i=[-60:35:70]){
                    translate([20,i])rotate([0,0,10])
                        minkowski(){
                            square([80,8]);
                            circle(2);
                        }
                }
            }
            
        }
        
    }
}

module padshape(){

if (render_part=="center") padshape_center();
if (render_part=="sides") padshape_sides();

}


module nub(){
    difference() {
        linear_extrude(height=nub_z) {
            hull() {
                for(x=[-1:2:1]) {
                    translate([x*(nub_x/2-nub_rx),0])
                    circle(nub_rx);
                }
                for(y=[-1:2:1]) {
                    translate([0,y*(nub_y/2-nub_ry)])
                    circle(nub_ry);
                }
            }
        }
        translate([0,0,nub_z]) scale([nub_x/nub_y,1,nub_concavity]) sphere(1.05*min(nub_x/2,nub_y/2));
    }
}

module texture(){
    for(x=[0:x_spacing:p_length]) {
        for(y=[0:y_spacing:p_width]) {
            translate([x,y,0]) nub();
            translate([x+x_spacing/2,y+y_spacing/2,0]) nub();
        }
    }
}

module pad(){
    linear_extrude(p_thick)padshape();
    intersection(){
        translate([p_x_offset,p_y_offset,p_thick])texture();
        linear_extrude(p_thick+nub_z)padshape();
    }
}

translate([0,55,0])pad();
if (render_part=="sides")translate([0,-55,0])rotate([0,0,180])mirror([1,0,0])pad();