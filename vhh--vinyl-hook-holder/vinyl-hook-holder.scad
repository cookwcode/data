// Default Parameters (mm)
lengthBase = 130; // Length of the base
widthGap = 11;    // Width of the gap holding the record
widthWall = 4;    // Wall thickness
heightBase = widthWall;  // Height of the base
front = 13;  // Front wall height
heightFront = front + widthWall;  // Total height of the front wall
lengthMount = 22;  // Length of the back mount
heightMount = 50;  // Height of the back mount

module vinyl_hook_holder(
    lengthBase=lengthBase, 
    widthGap=widthGap,
    widthWall=widthWall, 
    heightBase=heightBase, 
    heightFront=heightFront, 
    lengthMount=lengthMount, 
    heightMount=heightMount
    ) {
        // Setup
        widthBase = widthGap + (2 * widthWall);  // Width of the base
        moveFront = (widthBase / 2) - (widthWall / 2);  // Front wall position
        moveBack = -moveFront;  // Back wall position

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

        // Back mount
        translate([0, moveBack, 0]) {
            color("green", 0.5) {
                linear_extrude(heightMount) {
                    square([lengthMount, widthWall], center = true);
                }
            }
        }
}

module test_widths() {
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
