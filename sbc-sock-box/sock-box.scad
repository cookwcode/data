$fn = 100;
EPS = 0.01;

// Default Parameters (inches)
box_width_in = 3; 
box_height_in = 3;    
box_depth_in = 9;     
wall_thickness_in = 0.125;  

module SockBox(
    width_in = box_width_in,
    height_in = box_height_in, 
    depth_in = box_depth_in,
    wall_thickness_in = wall_thickness_in
) {
    // Convert inches to millimeters
    width_mm = width_in * 25.4;
    height_mm = height_in * 25.4;
    depth_mm = depth_in * 25.4;
    wall_thickness_mm = wall_thickness_in * 25.4;
    
    // Calculate internal dimensions
    int_width = width_mm - (2 * wall_thickness_mm);
    int_depth = depth_mm - (2 * wall_thickness_mm);
    int_height = height_mm - wall_thickness_mm;  // No top wall - open in Z direction
    
    difference() {
        // Outer box
        color("blue", 0.3) {
            cube([width_mm, depth_mm, height_mm], center = false);
        }
        
        // Inner cavity (hollow out the box)
        translate([wall_thickness_mm, wall_thickness_mm, wall_thickness_mm]) {
            color("red", 0.5) {
                cube([int_width, int_depth, int_height + EPS], center = false);
            }
        }
    }
}

// Main
SockBox();