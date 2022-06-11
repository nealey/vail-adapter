// Make circles lovely and round
$fa = 1; $fs = 0.5;

module fancycube(vec, h) {
    translate([r / 2, r / 2, 0]) {
        difference() {
            cube([r + 0.01, r + 0.01, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true);

        }
    }
}

union() {
    translate([0, 0, 11]) rotate(180, [1, 0, 0]) import("seeed_xaio_lid.stl", convexity=3);
    translate([2, -4.5, 0]) cube([8, 9, 4]);
    fillet(200, 1);
}
