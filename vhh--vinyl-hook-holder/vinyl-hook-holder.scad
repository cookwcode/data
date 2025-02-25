// Parameters (mm)
lengthBase = 130; // Length of the base
widthGap = 11;    // Width of the gap holding the record
widthWall = 4;    // Wall thickness
widthBase = widthGap + widthWall;  // Width of the base
heightBase = widthWall;  // Height of the base
front = 13;  // Front wall height
heightFront = front + widthWall;  // Total height of the front wall
moveFront = (widthBase / 2) - (widthWall / 2);  // Front wall position
moveBack = -moveFront;  // Back wall position
lengthMount = 22;  // Length of the back mount
heightMount = 50;  // Height of the back mount

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