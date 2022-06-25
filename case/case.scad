// Make circles lovely and round
$fa = 1; $fs = 0.1;

outer_dimensions = [24.2, 21, 25];
outer_radius = 3.7;
wall_width = [1.3, 1.3, 1.3];
inner_dimensions = outer_dimensions - (wall_width * 2);
inner_radius = outer_radius * 0.64;
z_elevate = [[0, 0, 0], [0, 0, 0], [0, 0, 0.5]]; // Multiply by this to bring bottom to z=0
center = [[-0.5, 0, 0], [0, -0.5, 0], [0, 0, 0]]; // Multiply by this to center something on the xy axes
xiao_elevation = 5.2; // Center of the PCB
pcb_thickness = 1.8;
channel = [16, 1, 1]; // Difensions of cap channel
channel_height = 2; // How far into the case the clips need to go
cap_thickness = 1.3;

module roundedcube(size=[1, 1, 1], center=false, r=0.5) {
    size = (size[0]==undef) ? [size, size, size] : size;
    cubeSize = [size[0] - 2*r, size[1] - 2*r, size[2]];

    translate(center ? [0,0,0] : size/2) {
        union() {
            cube([size[0], cubeSize[1], size[2]], center=true);
            cube([cubeSize[0], size[1], size[2]], center=true);
            for (ymul = [-0.5, 0.5]) {
                for (xmul = [-0.5, 0.5]) {
                    translate([cubeSize[0]*xmul, cubeSize[1]*ymul, 0]) cylinder(h=size[2], r=r, center=true);
                }
            }
        }
    }
}

module trs_support() {
    intersection() {
        cube([10, 30, 12], center=true);
        rotate(-45, [0, 1, 0]) cube([10, 30, 12], center=true);
    }
}

module usb_c() {
    cube([10, 6.5, 3.15], center=true);
    translate([0, -3.25, 0]) rotate(90, [0, 1, 0]) cylinder(d=3.15, h=10, center=true);
    translate([0, 3.25, 0]) rotate(90, [0, 1, 0]) cylinder(d=3.15, h=10, center=true);
}


module case() {
    difference() {
        translate((outer_dimensions * z_elevate) + ([0, 0, -1] * cap_thickness)) {
            difference() {
                roundedcube(outer_dimensions, center=true, r=outer_radius);
                roundedcube(inner_dimensions, center=true, r=inner_radius);
                translate(-outer_dimensions/2) cube([100, 100, cap_thickness]);
            }
        }

        // USB C port
        translate([inner_dimensions[0]/2, 0, 0]) {
            translate([0, 0, xiao_elevation - 3.15/2]) usb_c();
            cube([10, 9.65, xiao_elevation*2 - 3.15], center=true);
        }

    }
}

module body() {
    difference() {
        union() {
            case();

            // Add some supports
            intersection() {
                union() {
                    translate([13, 10, 13]) rotate(60, [0, 0, 1]) trs_support();
                    translate([13, -10, 13]) rotate(-60, [0, 0, 1]) trs_support();

                    // Shelf for board to rest against
                    difference() {
                        translate([-8, 0, xiao_elevation]) cube([6, 19, 4], center=true);
                        translate([-6, 0, xiao_elevation]) rotate(45, [0, 0, 1]) cube(15, center=true);
                    }
                }
                translate(outer_dimensions * center) roundedcube(outer_dimensions, r=outer_radius);
            }


            // Eyes
            translate([-12, 4, 18]) sphere(r=1.2);
            translate([-12, -4, 18]) sphere(r=1.2);
        }

        // Smirk grin
        intersection() {
            translate([0, 0, 11]) rotate(90, [0, 1, 0]) {
                difference() {
                    cylinder(h=50, d=20, center=true);
                    cylinder(h=50, d=19, center=true);
                }
            }
            translate([-18.7, 0, 0]) cube(7);
        }

        // Channel in the back to make it easier to squeeze in the XIAO
        translate([-4.5, 0, xiao_elevation]) intersection() {
            cube([13, 100, pcb_thickness], center=true);
            roundedcube(inner_dimensions, center=true, r=cap_thickness);
        }

        // Channels for bottom insertion part thingy
        for (i = [-0.5, 0.5]) {
            translate([0, inner_dimensions[1]*i, channel_height-channel[2]/2]) {
                cube(channel, center=true);
            }
        }

        // Paddle contacts
        translate([0, 0, 10]) {
            // 8-32x 1/4 screws
            rotate(90, [1, 0, 0]) cylinder(h=30, d=4.0, center=true);

            // Hookup wire
            translate([0, 0, -2.5]) cube([1, 30, 0.8], center=true);
        }

        // 3.5mm TRS jack
        translate([10, 0, 14]) rotate(90, [0, 1, 0]) cylinder(h=3, d=6.0);

        // Piezo buzzer
        translate([0, 0, 10]) {
            translate([-12, 3.5, 0]) cube([5, 1, 1], center=true);
            translate([-12, -3.5, 0]) cube([5, 1, 1], center=true);
        }
    }
}

module cap() {
    inner = inner_dimensions * 0.97; // leave 5% slop
    union() {
        intersection() {
            roundedcube(outer_dimensions, center=true, r=outer_radius);
            translate([0, 0, cap_thickness/2]) cube([100, 100, cap_thickness], center=true);
        }
        intersection() {
            roundedcube(inner, center=true, r=inner_radius);
            translate(center * inner) cube([100, 100, cap_thickness+2.2]);
        }
        difference() {
            union() {
                for (i = [-0.5, 0.5]) {
                    translate([0, inner[1]*i, cap_thickness + channel_height - channel[2]*0.4]) { // 40% of channel z for slop
                        difference() {
                            cube(channel, center=true);
                            translate([0, channel[1]*i, channel[2]/2]) rotate(90*i, [1, 0, 0]) {
                                cube([channel[0], channel[1], channel[2]], center=true);
                            }
                        }
                    }
                }
            }
            cube([5, 200, 200], center=true);
            for (i = [-1, 1]) {
                translate([9.5*i, 0, 0]) cube([5, 200, 200], center=true);
            }
        }
    }
}

if (TARGET == "body") {
    body();
} else if (TARGET == "cap") {
    cap();
} else if (true == true) {
    color([0, 0.5, 0.5]) body();
    color([0.5, 0, 0.5]) translate([0, 0, -cap_thickness]) cap();
} else {
    roundedcube(10);
}
