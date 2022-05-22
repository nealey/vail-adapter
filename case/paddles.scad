
  
/*
           >>> COMPACT 3D-PRINTED PADDLES <<<
    Torbjørn Skauli, LA4ZCA (tskauli@gmail.com)
                  v2.0, December 2018
Iambic paddles designed for 3D-printing. The design is simple, but provides precise movement with adjustable force and travel. Design features include a printed rocker hinge, force adjustment by a sliding spring, travel adjustment using a modified screw, ergonomic grip and general simplicity and precision.
Changes in v2.0: The paddles have been made narrower, and the base is thinner. There is an option to remove the bottom mounting holes. The base extends under the paddles to protect them from being pushed upwards. The cable exit is on the side, to fit mounting on the QCX transceiver.
TODO:
-Arms 1-2 mm higher, spring channel longer towards contacts?
Materials:
- 3 printed parts
- 2 screws M3x5mm, cylinder head, with washers for adjustment if needed
- 1 screw M4 x 18-20mm, cylinder head, with lockwasher and nut
- Compression spring, 6-8 mm in diameter
- Compression spring, 4-5 mm in diameter
- Cable with plug as required, up to 3.5 mm diameter
Note: Nickel plated brass screws have been found to give the most reliable contact operation. Dimensions of screws, springs and cable can be changed in the code.
Assembly:
- First, prepare the 3D-printed parts by removing support material in the arm spring well and in the ends of the cable holes. Also remove any protuding edges and bumps by gently filing the surfaces.
- Place the large spring so that it is held between the paddles approximately in the middle of the spring well. Also place the small spring in the holes at the hinge. Temporarily slide the two paddles in place. Check the spring force on the paddles and adjust as desired by either moving the spring along the well or by bending the spring to change its length. Make sure that the small spring keeps the arms in place at the hinges during use.
- Remove 6-8 cm of the outer isolation (if present) of the cable and 1 cm of the inner isolation of each wire. Insert the cable from the back through the diagonal hole, and temporarily pull it out from the side "window". Insert the cable back into the other hole and press the cable bend into the window so that the outer isolation ends in the interior wiring well. This forms a strain relief.
- Prepare a 18-20 mm M4 screw with cylindrical head by grinding the outer 5 mm to flatten two opposing sides. Preferably align the flattened screw end with the slot in the screw head.
- Enter two M3 screws with cylindrical heads into the paddle arms, with the heads facing inwards. Clamp the dot and dash wire ends under these screw heads.
- Enter the M4 screw from the bottom and clamp the ground wire underneath the lockwasher. Tighten the nut quite firmly, while allowing a small amount of adjustment of the screw angle to set the travel distance.
- Place the spring between the paddles and slide them in place. Adjust travel by rotating the M4 screw. If the travel is asymmetric, it may be necessary to correct the difference by placing a washer under the head of one of the M3 screws in the paddle arms.
*/

//*************** Rendering output control
mountholes=true;//Whether to have mounting holes in bottom
cacc=4;         // accuracy of circles, multiplier for $fn. Use cacc=1 for dev/debug, =2-4 for final.
preview=0;      // =0 for print layout,
                // =1 or =2 for 1- or 2-arm assembly preview,
                // =3 for base only
                // =4 for arms print layout,
                // =5 base+attachment preview
                // =6 base modified for attachment to other cabinet
                // =7 attachment for inclusion in other cabinet
                // =8 rotation stopper for inclusion in other cabinet

//**************** main parameters of the design
wxbase=24;      // overall width, sets arm thickness etc.
lybasemin=40;   // length excl. knobs (normally 40, made longer below for QCX)
hzarm=20;       // height of main part of arm
wallt=2;        // wall thikckness
wallmin=2;      // min wall thickness under cable holes

dfinger=30;     // approx diameter of finger for curved knob. Also knob length.
lyknob=25;                             // total length of knob
rround=1;       // radius of rounded edges on knob
txknobmin=2;    // min. thickness of knob

yhinge=6.5;     // y position of hinge relative to back
dxwedge=4;      // height of hinge wedge
ahinginn=50;    // angles for inner and outer part of hinges
ahingout=80;
dstopper=1.5;   // diameter of stopper on top of hinge that keeps arm down

armsep=0.75;     // arm separation from all walls
dyarmrests=2;   // y width of resting and bounding surfaces for arms
minstroke=0.25; // minimum stroke length (at full dia of center screw)

//**************** parameters for non-printed parts
dscrew1=4;      // screw dia, also scales screw head height
dscrew2=3;      // screw dia, also scales screw head height
hscrhrel=2/3;   // screw head height and diam rel to diameter
dscrhrel=7/4;
dzcontact=0.1;    // extra height of all screws
dzsprwell=-1;   // height adjustment of spring well
dcable=4;       // cable diameter
dspring=9.5;    // spring diameter
dhingespring=5; // diameter of spring keeping hinge in place

//*************** Parameters for cabinet attachment, needed to make integrated paddle
daxis=6;        // Diameter of rotation axis tube
lyflange=22;    // Length and height of flange on axis tube
hzflange=13;
atthick=1.5;
rotsnaph=1;     // Height of snaps for paddle attachment rotation
rotstop=7;      // Size of rotation stopper shelf

//**************** parameters for rendering
gap=0.2;        // gap for loose fit
tol=0.025;      // general tolerance
nil=0.001;     // Negligible distance, to correct rendering


lybase=lybasemin; // length of basee ex. knobs
echo("Length of base (mm):",lybase);
hzwall=hzarm+armsep;                        // total height of walls
hzbase=2*wallmin+dcable;                    // height of base under arms
ycontact=lybase-1*dscrew1;                  // position of contact screw

wxarm=wxbase/2-wallt-armsep-hscrhrel*dscrew2-minstroke-dscrew1/2; // arm thickness is the remaining space after removing many contributions to total width
echo("Total height (mm):",hzwall+hzbase);
echo("Total width for QCX (mm):",wxbase+dcable);
echo("Max length of contact screws in arms (mm):",wxarm);
echo("Min length of contact screw in base (mm):",hzbase-hscrhrel*dscrew1+armsep+hzarm/2+dscrew2*dscrhrel/2);
echo("Min length to flatten contact screw in base (mm):",dscrew2*dscrhrel);
wxknob=wxarm+wallt+armsep+hscrhrel*dscrew2;
dxknob=hscrhrel*dscrew2;                    // x offset toward center rel to main arm
hzknob=hzarm;                               // height of knobs
lyarm=lybase-wallt-armsep/2;                // knob spaced armsep/2 from base front

y0sprwell=yhinge-wallt-armsep+dxwedge*tan(ahingout/2);        // starting pos of spring channel
sprfloort=wallt;                            // thickness of floor underneath spring
sprlen=wxbase-2*(wallt+armsep+sprfloort);   // length of spring

dxtip=wxbase/4;                             // diameter of rounded tip with attachment hole
dytip=(wxbase-dxtip)/2;                     // length of tip ex rouned part
rtip=dxtip*sqrt(2)/2;                       // radius of tip
ycentip=lybase+dytip-rtip/sqrt(2);          // center of rounded tip

module teardropHole(lh,rh){ // Hole with 45-degree teardrop shape
    rotate([90,0,0])
    rotate([0,0,45])
    union(){
        cylinder(h=lh,r1=rh,r2=rh,$fn=8*cacc);
        cube([rh,rh,lh]);
    };
};
module snap45(snaph,snapl){ // bumps to snap parts together, max angle 45 degrees
// snapl is length of bump, passed as parameter to allow tolerance
difference(){
    rsnap=snaph/(1-1/sqrt(2));
    translate([rsnap-snaph,-snapl/2,0])
    rotate([-90,0,0])
        cylinder(h=snapl,r=rsnap,$fn=5*cacc);
    translate([nil,-snapl/2,-rsnap])
        cube([2*rsnap,snapl,2*rsnap]);
};
}; // end snap
module wedge(a,wx,hz){ // Equilateral triangular block
   //top angle a(deg), length hz and triangle height wx in x direction
    linear_extrude(height=hz)
    polygon([[0,0],[wx,wx*tan(a/2)],[wx,-wx*tan(a/2)]]);
};
module cone45(dc){ // cone for stopper that keeps arm down, 45-degree slope
    rotate([180,0,0])
    cylinder(d1=dc,d2=0,h=dc*1.0,$fn=8*cacc);
};
module wedge_hinge(){    //wedge on wall for hinge, with cutout so that arm rests on top and bottom
    // cutout for stopper cone
    translate([0,0,hzwall])
    cone45(dstopper);
    // wedge with cutout, centered on the edge between cone and armrest,
    // to make arm better supported against up-down tilt
    difference(){
        wedge(a=ahinginn,wx=dxwedge,hz=hzwall);
        translate([-hzarm/2/sqrt(2),hzarm/2,hzarm/2+armsep-dstopper*0.75/2])
        rotate([90,0,0])
        cylinder(h=hzarm,d=hzarm,$fn=12*cacc);
    };
};
module bump45(bumph){ // Spherical bump with at most 45 degree angle
rotate([0,180,0])
difference(){
    amax=60; // max overhang angle on bump, not necessarily 45 degerees
    rsnap=bumph/(1-cos(amax));
    translate([rsnap-bumph,0,0])
        sphere(r=rsnap,$fn=5*cacc);
    translate([nil,-rsnap,-rsnap])
        cube([2*rsnap,2*rsnap,2*rsnap]);
};
};
module rotsnaps(snaph){ // Rotation snaps for paddle
        rrot=(hzbase+hzwall)/2*sqrt(2)-snaph/(1-1/sqrt(2))-wallt;
        for (a=[45:90:360])
            rotate([a,0,0])
            translate([0,rrot,0])
            bump45(snaph);
};
module base_add(){ // parts of base that add to shape
    // base plate
    translate([-wxbase/2,0,0])
    cube([wxbase,lybase+lyknob-rround,hzbase]);
    
    //rounded front
    translate([-wxbase/2+rround,lybase+lyknob-rround,0])
    minkowski(){
        cube([wxbase-2*rround,tol,hzbase]);
        // rounding cy
        cylinder(r=rround,h=tol,$fn=cacc*4);
    };

    // walls
    translate([0,0,hzbase])
    difference(){
        translate([-wxbase/2,0,0])
        cube([wxbase,lybase,hzwall]);
        translate([-wxbase/2+wallt,wallt,0])
        cube([wxbase-2*wallt,lybase,hzwall+tol]);
    }
    
    //wedge 1
    translate([wxbase/2-wallt-dxwedge,yhinge,hzbase])
    wedge_hinge();
    //wedge 2
    translate([-(wxbase/2-wallt-dxwedge),yhinge,hzbase])
    rotate([0,0,180])
    wedge_hinge();
    
    // bottom arm resting surface, height armsep above base top
    translate([0,yhinge,hzbase])
    cube([wxbase-2*wallt-2*dxwedge-2,dyarmrests,2*armsep],center=true);
    
    // front arm lower resting surface, normally with 2*gap airgap
    translate([-wxbase/2,lybase-dyarmrests,hzbase])
    cube([(wxbase-2*dscrew1)/2,dyarmrests,armsep-2*gap]);
    translate([wxbase/2,lybase,hzbase])
    rotate([0,0,180])
    cube([(wxbase-2*dscrew1)/2,dyarmrests,armsep-2*gap]);
    
    // outer end stops, 2mm wide
    translate([-(wxbase/2-wallt),lybase-dyarmrests,hzbase])
    cube([armsep,dyarmrests,hzwall]);
    translate([(wxbase/2-wallt)-armsep,lybase-dyarmrests,hzbase])
    cube([armsep,dyarmrests,hzwall]);
    
    // extra column for center screw stability
    translate([0,ycontact,hzbase])
    cylinder(d=dscrew1*dscrhrel*1.5,h=dscrew1/2+dzcontact,$fn=8*cacc);
    
    // QCX attachment: add 1x cable dia of wall thickness and rotation axis
    if (preview>=5){
        
        // Thicker wall
        translate([wxbase/2,0,0])
        cube([dcable,lybase,hzbase+hzwall]);
        
        // Rotation stopper
        translate([wxbase/2,lybase,0])
        cube([dcable,rotstop,hzbase]);
        
        // snaps for paddle rotation
        translate([wxbase/2+dcable,lybase/2,(hzbase+hzwall)/2])
        rotsnaps(rotsnaph);
                
    };
    
};
module base_sub(){  // parts of base that cut away from shape
    
    // center contact screw hole
    translate([0,ycontact,0])
    cylinder(d=dscrew1,h=hzbase*9,$fn=8*cacc);

    // center contact screw head recess (20% enlarged) filled in by cylinder to avoid need for support
    translate([0,ycontact,0])
    cylinder(d=dscrew1*dscrhrel*1.2,h=dscrew1*hscrhrel*1.2,$fn=8*cacc);
    
    // Front mounting screw hole with recess
    if (mountholes && preview<5){
        translate([0,ycentip,0])
        cylinder(d=dscrew1+gap,h=hzbase,$fn=8*cacc);
        translate([0,ycentip,wallt])
        cylinder(d=dscrew1*dscrhrel*1.2,h=hzbase,$fn=8*cacc);
    };
    
    // wire well
    wellw=wxbase/2; // wire well width and length
    translate([wellw/2,ycontact-2*dscrew1,wallt])
    rotate([0,0,180])
    cube([wellw,wellw,hzbase]);

    // Back mounting screw hole in well
    if (mountholes && preview<5){
        translate([0,ycontact-2*dscrew1-wellw/2,0])
        cylinder(d=dscrew1+gap,h=hzbase,$fn=8*cacc);
    };
    
    //cable holes
    if (preview<5) // Free standing paddle, no attachment
    translate([-(wxbase/2-dcable/4),ycontact-2*dscrew1-wellw-dcable/2,dcable/2+wallmin]){
        // cable hole 1
        translate([0,-dcable/2,0])
        rotate([0,0,90])
        teardropHole(lh=wxbase*2,rh=dcable/2);
        // cable hole 2
        rotate([0,0,45+90])
        teardropHole(lh=wxbase/sqrt(2)/2,rh=dcable/2);
        //cable access opening
        cube([dcable,2*dcable,dcable],center=true);
        }
    else{ // Cable routing for QCX
        // cable hole from well
        translate([0,lybase/2+dcable,dcable/2+wallmin])
        rotate([0,0,90])
        teardropHole(lh=wxbase,rh=dcable/2);
        
        //cable access opening, printable without support, using breakaway wall
        for (i=[-1,1])
        translate([wxbase/2+0*wallt/2,lybase/2+i*(gap+dcable/2), wallmin]){
            cube([dcable,dcable,dcable]);
            translate([0,dcable/2,1.5*dcable])rotate([0,90,0])wedge(90,dcable/2,dcable);
        };

        //vertical cable hole
        translate([wxbase/2+dcable-(wallt+dcable)/2,lybase/2,wallmin]){
            hhole=hzbase+hzwall/2;
            cylinder(d=dcable,h=hhole); // main hole
            translate([0,0,hhole])
            cylinder(d1=dcable,d2=0,h=dcable); // tapered top to avoid support
        };
        
        // rotation axis
        translate([wxbase/2-dcable,lybase/2,(hzbase+hzwall)/2]){
            // Axis hole
            rotate([0,90,0])
            cylinder(d=daxis+gap,h=99,$fn=8*cacc);
            // Rotation snap
        };
        
        // Room for square flange soldered onto rotation axis
        translate([wxbase/2-wallt,(lybase-lyflange)/2,(hzbase+hzwall-hzflange)/2]){
            cube([dcable,lyflange,hzflange]);
            translate([-tol,0,hzflange-tol])
            rotate([90,-135,180])
               wedge(90,dcable/sqrt(2),lyflange);
        };
        
    }; // End QCX attachment

};
module base(){ // complete base part
    difference(){
        base_add();
        base_sub();
    };
};
module attachment(){ // attachment that can be included in QCX (or other) cabinet
    difference(){
    union(){
        
        // Attachment part of wall
        translate([0,-2*rotstop,0])
        cube([atthick,2*rotstop+lybase,hzbase+hzwall]);
        
        }; // end union
        
        // Axis hole
        translate([0,lybase/2,(hzbase+hzwall)/2])
        rotate([0,90,0])
        cylinder(d=daxis+gap,h=99,$fn=8*cacc);

        // snaps for paddle rotation, slightly tight to avoid play
        translate([0,lybase/2,(hzbase+hzwall)/2])
        rotsnaps(rotsnaph-gap/3);
        
    }; // end difference
};
module rotlimit(){ // Rotation stopper for attachment, to be included in cabinet

        limdim=wallt+dcable; // width of stopper cube, equal to stopper on paddle base

        // stopper knob
        translate([-dcable,lybase/2-limdim/2,(hzbase+hzwall)/2-limdim/2])// move to hole
        rotate([0*30,0,0]) // rotate if desired
        translate([0,-lybase/2-limdim/2-rotstop,(hzbase+hzwall)/2-limdim/2])
        cube([dcable,limdim,limdim]);
        
};
module rotlimitEXPORT(){ // Rotation stopper for attachment, to be included in cabinet
        translate([0,-lybase,-hzbase-hzwall])
        rotlimit();
};
module attachmentEXPORT(){ // Rotation stopper for attachment, to be included in cabinet
        translate([0,-lybase,-hzbase-hzwall])
        attachment();
};
function attachHeightEXPORT()=hzbase+hzwall; // Export total height
module arm_add(){  // arm base shape, without knob
    
    // main arm
    cube([wxarm,lyarm,hzarm]);
    
    // extra material for supporting hinge spring
    translate([-dxknob,0,0])
    cube([dxknob,y0sprwell,hzarm]);
    
    // extra material near top of arm, for stiffness and appearance
    hzarmextra=hzarm/2-dzcontact-(dscrew2*dscrhrel*1.3);
    translate([-dxknob,0,hzarm-(hzarmextra-dxknob)]){
        cube([dxknob,lyarm,hzarmextra-dxknob]);
        
        // 45 deg underside of extra material, to avoid generation of support
        translate([dxknob,0,0])
        rotate([90,45,180])
        wedge(90,dxknob/sqrt(2),lyarm);
    }
    
};
module arm_sub(){  // arm shaping
    // hinge groove
    translate([wxarm-dxwedge+armsep,yhinge-wallt-armsep,0])
    wedge(a=ahingout,wx=dxwedge,hz=hzarm);
    
    // hinge stopper cutout
    translate([wxarm-dxwedge+armsep,yhinge-wallt-armsep,hzarm])
    cone45(dstopper+2*gap);
    
    // tension spring channel
    translate([0,y0sprwell,(hzarm-dspring)/2+dzsprwell]){
        cube([wxarm-sprfloort,ycontact-y0sprwell-2.5*dscrew1,dspring]);
        translate([-tol,0,dspring-tol])
        rotate([90,-135,180])
        wedge(90,(wxarm-sprfloort)/sqrt(2),ycontact-y0sprwell-2.5*dscrew1);
    };
    
    // contact screw hole
    translate([-tol,ycontact-wallt-armsep,hzarm/2+dzcontact])
    rotate([0,0,90])
    teardropHole(lh=wxarm*2,rh=dscrew2/2-gap);

    // hole for spring keeping hinge in place
    translate([-dxknob-tol,yhinge-wallt-armsep,hzarm/2])
    rotate([0,0,90])
    teardropHole(lh=dxknob+wxarm-dxwedge+armsep-sprfloort+tol,rh=dhingespring/2);
    
    // extra space for center screw column
    translate([-(wxbase/2-wallt-armsep-wxarm),ycontact-wallt-armsep,0])
    cylinder(d=dscrew1*dscrhrel*1.5+2*minstroke+dscrew1,h=dscrew1/2+dzcontact+dscrew1*hscrhrel*1.25,$fn=8*cacc);

    
    };
    
module knob_curved(){ // finger-curved and rounded knob
    intersection(){ // cutting to outer shape
        minkowski(){ // rounding of edges
            
            // un-rounded knob shrunk by rounding radius
            difference(){ // shaping finger rest

                // knob, to be shaped by subtraction
                translate([-dxknob,lyarm,0])
                cube([wxknob-rround,lyknob-rround,hzknob-rround]);
                
              // shaping of knob
                translate([-dxknob+txknobmin+dfinger/2,lyarm+0*wallt+dfinger/2,dfinger/2+0*wallt])
                minkowski(){
                    cube([tol,wxbase,wxbase]);
                    sphere(r=dfinger/2,$fn=8*cacc);
                };
            };
            // rounding sphere
            sphere(r=rround,$fn=cacc*4);
        };
        // outer bound of knob
        translate([-dxknob,lyarm,0])
        cube([wxknob,dfinger,hzknob]);
    };

};
module arm(){ // Generate final shape according to preview and cacc settings
    difference(){
        union(){
            knob_curved();
            arm_add();
        };
        arm_sub();
    };
};
module build_all(){
    
    if(preview==1){
        base();
        translate([wxbase/2-wallt-armsep-wxarm,wallt+armsep,hzbase+armsep])
        arm();
    }
    else if (preview==2){
        base();
        translate([wxbase/2-wallt-armsep-wxarm,wallt+armsep,hzbase+armsep])
        arm();

        translate([-(wxbase/2-wallt-armsep-wxarm),wallt+armsep,hzbase+armsep])
        scale([-1,1,1])
        arm();
    }
    else if (preview==3){
        base();
    }
    else if (preview==4){
        translate([wxbase/2+wxknob+1,0,0])
        scale([-1,1,1])
        arm();
        
        translate([wxbase/2+2*wxknob+2,0,0])
        arm();
    }
    else if (preview==5){
        base();
        translate([wxbase/2+dcable+10,0,0]){ // spacing for rendering, for preview of fit
        attachment();
        rotlimit();
        };
    }
    else if (preview==6){ // Base with additions for attachment
        base();
    }
    else if (preview==7){ // Attachment for inclusion in cabinet
        attachmentEXPORT();
    }
    else if (preview==8){ // Rotation stopper for inclusion in cabinet
        rotlimitEXPORT();
    }
    else if (preview==9){ // Rotation stopper for inclusion in cabinet
        attachmentEXPORT();
        rotlimitEXPORT();
    }
    else{
        base();
        translate([wxbase/2+wxknob+1,0,0])
        scale([-1,1,1])
        arm();
        
        translate([wxbase/2+2*wxknob+2,0,0])
        arm();
        
    };
};
build_all();
