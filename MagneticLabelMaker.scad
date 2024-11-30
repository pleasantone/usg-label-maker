// Magnetic Label Maker by Pleasant One remixed from Josh
// See documentation for License.

labels0 = ["TESTING"];

labels1 = ["SAE SOCKETS", "RATCHETS", "RATCHETS", "SCREWDRIVERS", "WRENCHES", "TORQUE WRENCHES", "PLIERS", "BIT SETS", "POWER TOOLS", "ELECTRICAL", "PUNCHES", "BED SIZE TEST"];

labels2 = ["CHISELS", "PICKS", "TORX", "ALLEN", "JUNK", "RIVETING", "SHEARS", "MEASURING", "MISC", "PPE"];

labels3 = ["MOTORCYCLE", "MARKING", "MAGNETS", "PRY BARS", "BRUSHES", "CRIMPERS"];

labels = labels1;  // the labels we're going to print


// font should either be installed or font file should be in
// the same directory as the this file
// Avionic is quite close to the "U.S. GENERAL" font that Harbor
// Freight uses, but pick your favorite.
font = "FONTSPRING DEMO \\- Avionic Wide Oblique Black:style=Regular";
letter_size = 8;    // mm

depth = 5;          // total depth of badge (lettering and base)
radius = 2;         // box border

// if true, base flows with letter shapes, but slow to render
// and can do weird stuff with the letters with descenders
// may be more aesthetically pleasing on a case-by-case basis
base_follows_letters = false;

base_color = "black"; // only used for painting in preview, does not translate to STL
text_color = "white";

bed_size=[255, 255]; // printer bed size (BambuLab A1/P1/X1 are 255x255x255)

magnet_depth = 3.75;
magnet_diameter = 8;

label_y_offset = 20;  // distance between labels on plate

$fn = 32; // Model detail, higher is more detail and more processing

module makelabel(string, y_offset) {
    tmetrics = textmetrics(string, size = letter_size, font = font, halign = "center", valign = "center", $fn=64);

    box_width = tmetrics["size"][0];
    box_height = tmetrics["size"][1];

    // double-check that a single label won't be too wide
    assert(box_width+radius < bed_size[0]);

    // move to the y-offset in case multiple labels are happening
    translate([0, y_offset, 0]) difference() {
        union() {
            // make the base
            color(base_color) hull() { // wrap all words
                minkowski() { // chamfer corners and flow letters
                    linear_extrude(depth/2) {
                        if (base_follows_letters) {
                            text(string, size=letter_size, font=font, halign="center", valign="center", $fn = 64);
                        } else {
                            square([box_width, box_height], center=true);
                        }
                    }
                    cylinder(h=1, r=radius);
                }
            }

            // make the raised text
            color(text_color) linear_extrude(depth) {
                text(string, size = letter_size, font = font, halign = "center", valign = "center", $fn = 64);
            }
        }

        // carve out  magnet holes (difference)
        translate([0, 0, 0]) {
            // center or only magnet hole
            cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
            };

            // add two additional magnet holes
            if (box_width + radius > 36.0) {
                translate([-box_width/2 + 10, 0, 0]) {
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };

                translate([box_width/2 - 10, 0, 0]) {
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };
            }
    }
}

// SCAD is a functional language
// so variables only get set once per function
// so we do things recursively
module makelabels(labels, idx = 0) {
    offset = idx * label_y_offset;
    if (idx < len(labels) && offset < bed_size[1] - (label_y_offset*2)) {
        makelabel(labels[idx], offset);
        makelabels(labels, idx + 1);
    } else {
        echo(str("WARNING: Not enough room to print ", labels[idx]));
    }
}

makelabels(labels);
