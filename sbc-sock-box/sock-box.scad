$fn = 100;
EPS = 0.01;

// Default Parameters (inches)
box_width_in = 3.5; 
box_height_in = 3;    
box_depth_in = 9;     
wall_thickness_in = 0.125;
corner_radius_in = 0.125;  // Internal corner radius

// Hole parameters
front_back_hole_diameter_in = 1;  // Diameter of holes in front/back walls
side_hole_diameter_in = 0.75;      // Diameter of holes in side walls  
side_hole_spacing_in = 1.25;         // Spacing between holes along sides
bottom_hole_diameter_in = 0.5;      // Diameter of holes in bottom
bottom_hole_spacing_in = 1.0;       // Spacing between holes in bottom grid  

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
    corner_radius_in = corner_radius_in,
    front_back_hole_diameter_in = front_back_hole_diameter_in,
    side_hole_diameter_in = side_hole_diameter_in,
    side_hole_spacing_in = side_hole_spacing_in,
    bottom_hole_diameter_in = bottom_hole_diameter_in,
    bottom_hole_spacing_in = bottom_hole_spacing_in
) {
    // Convert inches to millimeters
    width_mm = width_in * 25.4;
    height_mm = height_in * 25.4;
    depth_mm = depth_in * 25.4;
    wall_thickness_mm = wall_thickness_in * 25.4;
    corner_radius_mm = corner_radius_in * 25.4;
    front_back_hole_diameter_mm = front_back_hole_diameter_in * 25.4;
    side_hole_diameter_mm = side_hole_diameter_in * 25.4;
    side_hole_spacing_mm = side_hole_spacing_in * 25.4;
    bottom_hole_diameter_mm = bottom_hole_diameter_in * 25.4;
    bottom_hole_spacing_mm = bottom_hole_spacing_in * 25.4;
    
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
        
        // Front wall hole (centered in XZ plane)
        translate([width_mm/2, -EPS, height_mm/2]) {
            rotate([-90, 0, 0]) {
                cylinder(d = front_back_hole_diameter_mm, h = wall_thickness_mm + 2*EPS);
            }
        }
        
        // Back wall hole (centered in XZ plane)
        translate([width_mm/2, depth_mm - wall_thickness_mm - EPS, height_mm/2]) {
            rotate([-90, 0, 0]) {
                cylinder(d = front_back_hole_diameter_mm, h = wall_thickness_mm + 2*EPS);
            }
        }
        
        // Left side holes (periodic along Y direction)
        for (y = [side_hole_spacing_mm : side_hole_spacing_mm : depth_mm - side_hole_spacing_mm]) {
            translate([-EPS, y, height_mm/2]) {
                rotate([0, 90, 0]) {
                    cylinder(d = side_hole_diameter_mm, h = wall_thickness_mm + 2*EPS);
                }
            }
        }
        
        // Right side holes (periodic along Y direction)  
        for (y = [side_hole_spacing_mm : side_hole_spacing_mm : depth_mm - side_hole_spacing_mm]) {
            translate([width_mm - wall_thickness_mm - EPS, y, height_mm/2]) {
                rotate([0, 90, 0]) {
                    cylinder(d = side_hole_diameter_mm, h = wall_thickness_mm + 2*EPS);
                }
            }
        }
        
        // Bottom holes (grid pattern in XY plane)
        // Calculate number of holes and centering offset for width
        num_holes_x = floor((width_mm - 2*wall_thickness_mm) / bottom_hole_spacing_mm);
        total_width_holes = (num_holes_x - 1) * bottom_hole_spacing_mm;
        x_offset = (width_mm - total_width_holes) / 2;
        
        for (x_i = [0 : num_holes_x - 1]) {
            for (y = [bottom_hole_spacing_mm : bottom_hole_spacing_mm : depth_mm - bottom_hole_spacing_mm]) {
                translate([x_offset + x_i * bottom_hole_spacing_mm, y, -EPS]) {
                    cylinder(d = bottom_hole_diameter_mm, h = wall_thickness_mm + 2*EPS);
                }
            }
        }
    }
}

// Main
SockBox();