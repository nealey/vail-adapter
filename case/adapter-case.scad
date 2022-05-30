use <threadlib/threadlib.scad>

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
    }

    translate([10, -4.79, 4.79]) cube([5, 9.58, 3]);
    translate([10, 0, 9]) cube([10, 18.36, 6], center=true);


    translate([0, 0, 9.5]) rotate(90, [1, 0, 0]) cylinder(h=30, d=0.8, center=true);
    translate([0, -9, 12]) rotate(90, [1, 0, 0]) tap("M4", turns=3);
    translate([0, 11, 12]) rotate(90, [1, 0, 0]) tap("M4", turns=3);

    translate([11, 0, 18]) rotate(90, [0, 1, 0]) tap("M6", turns=3); //cylinder(h=50, r=4);
}
