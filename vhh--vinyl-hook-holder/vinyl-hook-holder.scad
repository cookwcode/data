lengthBase = 130; // Length of the base
widthGap = 11;  // Width of the gap holding the record
widthWall = 4; // Wall thickness
widthBase = widthGap + widthWall;  // Width of the base
heightBase = widthWall;  // Height of the rectangle
front = 13;
heightFront = front + widthWall;
moveFront = (widthBase / 2) - (widthWall / 2);
moveBack = -moveFront;
lengthMount = 22;
heightMount = 50;

// base
color("blue", 0.5)
linear_extrude(heightBase) {
    square([lengthBase, widthBase], center = true);
}

// front wall
translate([0, moveFront, 0]) {
    color("red", 0.5)
    linear_extrude(heightFront) {
        square([lengthBase, widthWall], center = true);
    }
}

// back wall
translate([0, moveBack, 0]) {
    color("purple", 0.5)
    linear_extrude(heightFront) {
        square([lengthBase, widthWall], center = true);
    }
}

// back mount
translate([0, moveBack, 0]) {
    color("green", 0.5)
    linear_extrude(heightMount) {
        square([lengthMount, widthWall], center = true);
    }
}