// Default Parameters (mm)
lengthBase = 130; // Length of the base
widthGap = 11;    // Width of the gap holding the record
widthWall = 4;    // Wall thickness
heightBase = widthWall;  // Height of the base
heightFrontWall = 13;  // Front wall height, excluding the base
heightMount = 50;  // Height of the back mount

module vinyl_hook_holder(
    lengthBase=lengthBase, 
    widthGap=widthGap,
    widthWall=widthWall, 
    heightBase=heightBase, 
    heightFrontWall=heightFrontWall,
    heightMount=heightMount
    ) {
        // Setup
        widthBase = widthGap + (2 * widthWall);  // Width of the base
        heightFront = heightFrontWall + widthWall;  // Total height of the front wall
        moveFront = (widthBase / 2) - (widthWall / 2);  // Front wall position
        moveBack = -moveFront;  // Back wall position
        lengthMount = 0.7 * lengthBase;  // Length of the back mount

        // Base
        color("blue", 0.5) {
            linear_extrude(heightBase) {
                square([lengthBase, widthBase], center = true);
            }
        }

        // Front wall
        translate([0, moveFront, 0]) {
            color("red", 0.5) {
                linear_extrude(heightFront) {
                    square([lengthBase, widthWall], center = true);
                }
            }
        }

        // Back wall
        translate([0, moveBack, 0]) {
            color("purple", 0.5) {
                linear_extrude(heightFront) {
                    square([lengthBase, widthWall], center = true);
                }
            }
        }

        // Back mount (trapezoid)
        topLength = 30;
        translate([0, moveBack, 0]) {
            color("green", 0.5) {
            linear_extrude(height=heightMount, scale=[topLength / lengthMount, 1]) {
                square([lengthMount, widthWall], center=true);
            }
            }
        }
}

// Main --------------------
vinyl_hook_holder();

// Testing -----------------

module test_widths() {
    // Test different widths of inner channel
  vinyl_hook_holder(
    heightMount=0,
    lengthBase=40,
    widthGap=15
    );

    translate([0, 50, 0]) {
    vinyl_hook_holder(
        heightMount=0,
        lengthBase=40,
        widthGap=20
    );
    } 

    translate([0, 100, 0]) {
    vinyl_hook_holder(
        heightMount=0,
        lengthBase=40,
        widthGap=25
    );
    } 
}

// test_widths();