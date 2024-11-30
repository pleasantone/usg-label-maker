font = "FONTSPRING DEMO \\- Avionic Wide Oblique Black:style=Regular";
letter_size = 8;
depth = 5;

labels1 = ["SAE SOCKETS", "RATCHETS", "RATCHETS", "SCREWDRIVERS", "WRENCHES", "TORQUE WRENCHES", "PLIERS", "BIT SETS", "POWER TOOLS", "ELECTRICAL", "PUNCHES"];

labels2 = [ "CHISELS", "PICKS", "TORX", "ALLEN", "JUNK", "RIVETING", "SHEARS", "MEASURING", "MISC", "PPE"];

labels3 = [ "MOTORCYCLE", "MARKING", "MAGNETS", "PRY BARS", "BRUSHES", "CRIMPERS" ];

base_color = "black";
text_color = "white";

bed_size=[255, 255];

magnet_depth = 3.75;
magnet_diameter = 8;

label_y_offset = 20;

$fn = 32; // Model detail, higher is more detail and more processing

module makelabel(string, y_offset) {
    tmetrics = textmetrics(string, size = letter_size, font = font, halign = "center", valign = "center", $fn=64);

    box_width = tmetrics["size"][0]+6;
    box_height = tmetrics["size"][1]+6;

    // double-check that a single label won't be too wide
    assert(box_width<bed_size[0]);
    assert(box_height<bed_size[1]);

    // move to the y-offset in case multiple labels are happening
    translate([0, y_offset, 0]) difference() {
        union() {
            // make the base
            color(base_color) linear_extrude(depth / 2) {
                square([box_width, box_height], center = true);
            }

            // make the text part
            // color is just used for preview
            color(text_color) linear_extrude(depth) {
                text(string, size = letter_size, font = font, halign = "center", valign = "center", $fn = 64);
            }
        }

        // carve out holes (difference)
        translate([0, 0, 0]) {
            // center or only magnet hole
            cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
            };
            
            // add two additional magnet holes
            if (box_width > 36.0) {
                translate([-box_width/2 + 10, 0, 0]) {
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };
                
                translate([box_width/2 - 10, 0, 0]) {
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };
            }
    }
}

// recursive iteration because SCAD is a functional language
// so variables only get set once per function
module makelabels(labels, idx = 0) {
    offset = idx * label_y_offset;
    if (idx < len(labels) && offset < bed_size[1] - (label_y_offset*2)) {
        makelabel(labels[idx], offset);
        makelabels(labels, idx + 1);
    }
}

makelabels(labels3);
