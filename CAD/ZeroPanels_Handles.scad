/* [User Options] */
// Width of handle (mm)
handle_width = 85; // [60:120]
// Handle height (mm)
handle_height = 35; // [20:46]
// Thickness of handle (mm)
handle_thickness = 12; // [5:30]
// Thickness of pannel handle is mounted over (mm)
panel_thickness = 5; // [2:10]
// Size of screw hole (mm)
screw_thread_size = 3.2; // [1:0.1:10]
// Size of screw head (mm)
screw_head_size = 6; // [1:20]
// Size of extrusion (mm)
extrusion_size = 15; // [10:40]
// Size of slot in extrusion (mm)
extrusion_slot_size = 2.9; // [1:0.1:10]
// Thickness of slot interface (mm)
slot_interface_thickness = 1; // [1:5]
// Amount of screw holes
screw_holes = 4; // [2: 10]


/* [Hidden] */
$fn = 120;
handle_bridge_width = 6;
handle_bridge_sides = 12;
filet_radius = 15;
screw_head_margin = 2;

handle_assembly();

module filet(radius, thickness) {
    translate([-1, -1, -0.5])
        difference() {
            cube([radius+1, radius+1, thickness+1]);
            translate([radius+1, radius+1, -0.5])
                cylinder(h = thickness+2, r = radius);
        }
}

module screw_hole() {
    union() {
        translate([0, 0, -1]) {
            cylinder(h = handle_thickness+panel_thickness+slot_interface_thickness+2, d=screw_thread_size);
            cylinder(h = handle_thickness-screw_head_margin+1, d=screw_head_size);
        }
        translate([0, 0, handle_thickness-screw_head_margin]) 
            cylinder(h = 1, d1 = screw_head_size, d2 = screw_thread_size);
    }
}

module extrusion_interface() {
    difference() {
        union() {
            cube([handle_width, extrusion_size, panel_thickness]);
            translate([0, extrusion_size/2-extrusion_slot_size/2, panel_thickness]) 
                cube([handle_width, extrusion_slot_size, slot_interface_thickness]);
        }
        translate([-1, -1, -1]) 
            cube([handle_width+2, (extrusion_size-extrusion_slot_size)/2+1, panel_thickness+10]);
    }
}

module handle_hole() {
    translate([0, 0, -1]) {
        hole_width = handle_width-2*handle_bridge_sides;
        difference() {
            cube([hole_width, handle_height-handle_bridge_width, handle_thickness+2]);
            difference() {
                translate([-1, -1, -1]) 
                    cube([hole_width+2, handle_height-handle_bridge_width+2, handle_thickness+4]);

                translate([20, -2, -2]) 
                cube([hole_width-40, handle_height-handle_bridge_width+2, handle_thickness+6]);
                translate([20, 20, -2]) 
                cylinder(h = handle_thickness+6, r = 20);
                translate([hole_width-20, 20, -2]) 
                cylinder(h = handle_thickness+6, r = 20);
            }
        }
    }
}

module handle() {
    difference() {
        // Main handle
        cube([handle_width, handle_height+extrusion_size,  handle_thickness]);
        // Right filet
        translate([handle_width, handle_height+extrusion_size])
        rotate(180)
            filet(filet_radius, handle_thickness);
        // Left filet
        translate([0, handle_height+extrusion_size])
        rotate(270)
            filet(filet_radius, handle_thickness);
        
        translate([handle_bridge_sides, extrusion_size, 0])
            handle_hole();
    }
}

module handle_assembly() {
    difference() {
        union() {
            handle();
            translate([0, 0, handle_thickness]) 
                extrusion_interface();
        }
        spacing = (handle_width-screw_head_size)/screw_holes;
        translate([-spacing/2+screw_head_size/2, extrusion_size/2, 0]) {
            for (hole = [1:screw_holes]) {
                translate([hole*spacing, 0, 0]) 
                    screw_hole();
            }
        }
    }
}