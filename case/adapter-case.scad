// Make circles lovely and round
$fa = 1; $fs = 0.5;

module stacker() {
    translate([0, 0, -5]) {
        difference() {
            union() {
                import("seeed_xaio_case.stl", convexity=3);
                translate([-12.1, -2, 6]) cube([1.3, 4, 4]); // Plug up the component hole in the back
                translate([11.45, 0, 5]) cube([1.3, 10, 4], center=true); // Plug up the USB hole
            }
            cube([30, 25, 10], center=true);
        }
    }
}

module lid() {
    intersection() {
        import("seeed_xaio_case.stl", convexity=3);
        cube([30, 30, 4], center=true);
    }
}

module trs_support() {
    intersection() {
        cube([12, 25, 12], center=true);
        rotate(-45, [0, 1, 0]) cube([12, 25, 12], center=true);
    }
}

module pig_ear() {
    intersection() {
        cylinder(h=4, r1=2, r2=1, center=true);
        translate([0, -10, 0]) cube([20, 20, 20]);
    }
}

difference() {
    union() {
        import("seeed_xaio_case.stl", convexity=3);

        translate([-12.1, -2, 6]) cube([1.3, 4, 4]); // Plug up the component hole in the back

        // Overlap these to get rid of the slots inside
        translate([0, 0, 07.5]) stacker();
        translate([0, 0, 10.0]) stacker();
        translate([0, 0, 12.5]) stacker();
        translate([0, 0, 15.0]) stacker();
        translate([0, 0, 17.5]) stacker();
        translate([0, 0, 20.0]) stacker();
        translate([0, 0, 23]) lid();

        // Add some support for inserting the TRS plug
        intersection() {
            union() {
                translate([13, 10, 16]) rotate(60, [0, 0, 1]) trs_support();
                translate([13, -10, 16]) rotate(-60, [0, 0, 1]) trs_support();
            }
            cube([21.8, 19, 60], center=true);
        }

        // Shelf for board to rest against
        difference() {
            translate([-8, 0, 9.2]) cube([6, 19, 1], center=true);
            translate([-6, 0, 9.2]) rotate(45, [0, 0, 1]) cube(15, center=true);
        }

        // Pig Parts
        translate([-12, 4, 22]) sphere(r=1.3);
        translate([-12, -4, 22]) sphere(r=1.3);
        if (false) {
            translate([-8, 5, 25]) pig_ear();
            translate([-8, -5, 25]) pig_ear();
        }
    }

    // Pig grin
    intersection() {
        translate([0, 0, 15]) rotate(90, [0, 1, 0]) {
            difference() {
                cylinder(h=50, d=20, center=true);
                cylinder(h=50, d=19, center=true);
            }
        }
        translate([-18.7, 0, 0]) cube(7);
    }

    // Cut off the bottom
    cube([30, 30, 4.01], center=true);

    // Channel in the back to make it easier to squeeze in the XIAO
    translate([-4.5, 0, 7.6]) intersection() {
        cube([13, 18.3, 1.8], center=true);
        cylinder(d=21, h=300, center=true);
    }

    // Channels for bottom insertion part thingy
    translate([0, 0, 3.6]) cube([17, 18.8, 1.2], center=true);

    // Carve out above USB C port
    translate([10, -4.79, 0]) cube([5, 9.58, 5]);

    // Paddle contacts
    translate([0, 0, 12]) {
        // 8-32x 1/4 screws
        rotate(90, [1, 0, 0]) cylinder(h=30, d=4.0, center=true);

        // Hookup wire
        translate([0, 0, -2.5]) cube([1, 30, 0.8], center=true);
    }

    // 3.5mm TRS jack
    translate([10, 0, 18]) rotate(90, [0, 1, 0]) cylinder(h=3, d=6.0);

    // Piezo buzzer
    translate([0, 0, 13]) {
        translate([-12, 3.5, 0]) cube([5, 1, 1], center=true);
        translate([-12, -3.5, 0]) cube([5, 1, 1], center=true);
    }
}
