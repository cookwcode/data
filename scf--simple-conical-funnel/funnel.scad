$fn = 100;
EPS = 0.01;

module Funnel(outer_diameter, height, thickness, hole_size) {
    // calculations
    inner_diameter = outer_diameter - 2*thickness;
    outer_r = outer_diameter/2;
    inner_r = inner_diameter/2;
    angle = atan(height/outer_r);
    height_inner = inner_r * tan(angle);
    dist = hole_size / 2 * tan(angle);
    y_cut = height_inner - dist;
    
    // cone module
    module Cone() {
        difference() {
            color(c = "orange", alpha = 0.1) {
                cylinder(h = height, r1 = outer_diameter/2, r2 = 0);
            }
            translate([0, 0, -EPS]) {
                color(c = "blue", alpha = 0.5) {
                    cylinder(h = height_inner, r1 = inner_diameter/2, r2 = 0);
                } 
            }
        }
    }
    
    // hole module
    module Hole() {
        translate([0, 0, y_cut]) {
            cylinder(h = height / 2, r = outer_r);
        }
    }
    
    // create the funnel
    difference() {
        Cone();
        Hole();
    }
    
    echo("Actual height: ", y_cut);
}

// default parameters (mm)
Funnel(
    outer_diameter = 80,    // outer diameter of the funnel
    height = 130,           // height of the funnel (approximate)
    thickness = 3,          // thickness of the funnel wall
    hole_size = 17          // diameter of the hole at the bottom
);
