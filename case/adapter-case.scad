union() {
    import("seeed_xaio_case.stl", convexity=3);
    translate([-12.1, -2, 6]) cube([1.3, 4, 4]); // Plug up the component hole in the back

    // Fill in the curved sides in front
    translate([-13.5, -10.485, 0]) cube([5, 1.30, 10]);
    translate([-13.5, 9.185, 0]) cube([5, 1.30, 10]);

    // Big block for key
    translate([-40, -10.485, 0]) cube([29, 10.485*2, 10]);

    difference() {
        translate([-40, -10.485, 0]) cube([28, 10.485*2, 30]);
    }
    
}
