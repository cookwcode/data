$fn = 100;
EPS = 0.01;

// Default Parameters (inches)
box_width_in = 3; 
box_height_in = 3;    
box_depth_in = 9;     
wall_thickness_in = 0.125;
corner_radius_in = 0.125;  // Internal corner radius  

// Rounded cube module
module rounded_cube(size, radius) {
    x = size[0];
    y = size[1]; 
    z = size[2];
    
    hull() {
        translate([radius, radius, 0])
            cylinder(h = z, r = radius);
        translate([x - radius, radius, 0])
            cylinder(h = z, r = radius);
        translate([x - radius, y - radius, 0])
            cylinder(h = z, r = radius);
        translate([radius, y - radius, 0])
            cylinder(h = z, r = radius);
    }
}

module SockBox(
    width_in = box_width_in,
    height_in = box_height_in, 
    depth_in = box_depth_in,
    wall_thickness_in = wall_thickness_in,
    corner_radius_in = corner_radius_in
) {
    // Convert inches to millimeters
    width_mm = width_in * 25.4;
    height_mm = height_in * 25.4;
    depth_mm = depth_in * 25.4;
    wall_thickness_mm = wall_thickness_in * 25.4;
    corner_radius_mm = corner_radius_in * 25.4;
    
    // Calculate internal dimensions
    int_width = width_mm - (2 * wall_thickness_mm);
    int_depth = depth_mm - (2 * wall_thickness_mm);
    int_height = height_mm - wall_thickness_mm;  // No top wall - open in Z direction
    
    difference() {
        // Outer box - rounded corners
        color("blue", 0.3) {
            rounded_cube([width_mm, depth_mm, height_mm], corner_radius_mm);
        }
        
        // Inner cavity (hollow out the box) - rounded corners
        translate([wall_thickness_mm, wall_thickness_mm, wall_thickness_mm]) {
            color("red", 0.5) {
                rounded_cube([int_width, int_depth, int_height + EPS], corner_radius_mm);
            }
        }
    }
}

// Main
SockBox();