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

module trs_support() {
    intersection() {
        cube([12, 25, 12], center=true);
        rotate(-45, [0, 1, 0]) cube([12, 25, 12], center=true);
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

        // Add some support for inserting the TRS plug
        intersection() {
            union() {
                translate([13, 10, 16]) rotate(60, [0, 0, 1]) trs_support();
                translate([13, -10, 16]) rotate(-60, [0, 0, 1]) trs_support();
            }
            cube([22.5, 18, 60], center=true);
        }
    }

    // Carve out above USB C port
    translate([10, -4.79, 4.79]) cube([5, 9.58, 3]);

    // Carve out space to slide the XIAO in
    intersection() {
        translate([10, 0, 10]) cube([10, 18.36, 8], center=true);
        translate([10, 0, 6]) rotate(45, [1, 0, 0]) cube(15, center=true);
    }

    // Hookup wire
    translate([0, 0, 9.5]) cube([1, 30, 0.8], center=true);

    // 8-32x 1/4 screws
    translate([0, 0, 12]) rotate(90, [1, 0, 0]) cylinder(h=30, d=3.8, center=true);

    // 3.5mm TRS jack
    translate([10, 0, 18]) rotate(90, [0, 1, 0]) cylinder(h=3, d=5.5);

    // Piezo buzzer
    translate([-12, 3.5, 15]) cube([5, 1, 1], center=true);
    translate([-12, -3.5, 15]) cube([5, 1, 1], center=true);
}
