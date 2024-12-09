// Magnetic Label Maker by Pleasant One remixed from Josh
// See documentation for License.


/* [Labels] */
// The labels we're going to print
labels = ["TEST LABEL", "TEST LABEL2"];

label_group_a = ["SAE SOCKETS", "RATCHETS", "RATCHETS", "SCREWDRIVERS", "WRENCHES", "TORQUE WRENCHES", "PLIERS", "BIT SETS", "POWER TOOLS", "ELECTRICAL", "PUNCHES", "BED SIZE TEST"];
label_group_b = ["CHISELS", "PICKS", "TORX", "ALLEN", "JUNK", "RIVETING", "SHEARS", "MEASURING", "MISC", "PPE"];
label_group_c = ["MOTORCYCLE", "MARKING", "MAGNETS", "PRY BARS", "BRUSHES", "CRIMPERS","SOLDERING"];


/* [Font] */
/* Avionic Wide Oblique Black is quite close to the
   "U.S. GENERAL" font that Harbor Freight uses, but pick your
   favorite.

   These are all close:
   https://demofont.com/avionic-sans-serif-font/
   https://www.ffonts.net/sdprostreet-Regular.font
   https://www.ffonts.net/Concielian-Bold-Semi-Italic.font

   There are two ways to install private fonts, the easiest
   is to install it in your system. The other way is to add
   use </path/to/font/file.ttf> to this file and then set
   the font name as in:

   use <sd prostreet.ttf>
   font_name = "sd prostreet";
   */

//use <Avionic Font/Fontspring-DEMO-avionicqideoblique-black.otf>

// Text font
font_name = "FONTSPRING DEMO \\- Avionic Wide Oblique Black";

//alternatively:
//use <sd prostreet.ttf>
//font_name = "sd prostreet";

// Not all styles may work
font_style = ""; // [,Regular,Bold,Medium,SemiBold,Light,ExtraBold,Black,ExtraLight,Thin,Bold Italic,Italic,Light Italic,Medium Italic]
// Additional font styles listed in order of popularity, many may not work with your selected font_family
advanced_styles = ""; //[,SemiBold Italic,ExtraBold Italic,Black Italic,ExtraLight Italic,Condensed Bold,Condensed ExtraBold,Condensed Light,Condensed SemiBold,Thin Italic,Condensed ExtraLight,Condensed Medium,Condensed Thin,Condensed,Condensed Black,ExtraCondensed,SemiCondensed,ExtraCondensed Black,ExtraCondensed Bold,ExtraCondensed ExtraBold,ExtraCondensed ExtraLight,ExtraCondensed Light,ExtraCondensed Medium,ExtraCondensed SemiBold,ExtraCondensed Thin,SemiCondensed Black,SemiCondensed Bold,SemiCondensed ExtraBold,SemiCondensed ExtraLight,SemiCondensed Light,SemiCondensed Medium,SemiCondensed SemiBold,SemiCondensed Thin,Condensed Bold Italic,Condensed ExtraBold Italic,Condensed Italic,Condensed Light Italic,Condensed SemiBold Italic,Condensed ExtraLight Italic,Condensed Medium Italic,Condensed Regular,Condensed Thin Italic,Condensed Black Italic,12pt ExtraLight,12pt ExtraLight Italic,20pt Italic,20pt Regular,ExtraBlack,ExtraBlack Italic,ExtraCondensed Black Italic,ExtraCondensed Bold Italic,ExtraCondensed ExtraBold Italic,ExtraCondensed ExtraLight Italic,ExtraCondensed Italic,ExtraCondensed Light Italic,ExtraCondensed Medium Italic,ExtraCondensed SemiBold Italic,ExtraCondensed Thin Italic,SemiCondensed Black Italic,SemiCondensed Bold Italic,SemiCondensed ExtraBold Italic,SemiCondensed ExtraLight Italic,SemiCondensed Italic,SemiCondensed Light Italic,SemiCondensed Medium Italic,SemiCondensed SemiBold Italic,SemiCondensed Thin Italic]
// font size in points
font_size = 8.0;


/* [Base Properties] */
/* If true, base flows with letter shapes, but slower to render
   and can do weird stuff with the letters with descenders (Q)
   or trailing characters with reverse angles (L). It's pretty
   when it works out correctly but off by default to be safe
   for all cases. */

// Experimental: base outline follows letters
base_follows_letters = 0; // [0:Rectangle, 1:Outline letters]
// Rounded corner radius (default 2mm, 0 for sharp corners)
base_radius = 2.0;
// Total depth in mm of badge and base in mm (default 5mm)
depth = 5.0;
// Depth of the magnet hole in mm
magnet_depth = 3.75;
// Diameter of the magnet hole in mm
magnet_diameter = 8.0;
// If the piece is less than X mm, create only a single magnet hole, otherwise 3
single_magnet_width = 36.0;

/* [Preview colors settings (preview only, need to paint in slicer)] */
base_color = "black";
text_color = "white";

/* [Printer and offset settings] */
// distance between labels on plate
label_y_offset = 20.0;
// printer bed size (BambuLab A1/P1/X1 are 255x255x255)
bed_size=[255, 255];

/* [ Hidden ] */
$fn = 32; // Model detail, higher is more detail and more processing

if (font_style!="") {
    font = str(font_name, ":style=", font_style);
    makelabels(labels, font);
} else {
    if (advanced_styles!="") {
        font = str(font_name, ":style=", advanced_styles);
        makelabels(labels, font);
    } else {
        makelabels(labels, font_name);
    }
}

module makelabel(string, font, y_offset = 0) {
    tmetrics = textmetrics(string, size = font_size, font = font, halign = "center", valign = "center", $fn=64);

    base_width = tmetrics["size"][0];
    base_height = tmetrics["size"][1];

    // double-check that a single label won't be too wide
    assert(base_width+base_radius < bed_size[0]);

    // move to the y-offset in case multiple labels are happening
    translate([0, y_offset, 0]) difference() {
        union() {
            // make the base
            color(base_color) hull() { // wrap all words
                minkowski() { // chamfer corners and flow letters
                    linear_extrude(depth/2) {
                        if (base_follows_letters) {
                            text(string, size=font_size, font=font, halign="center", valign="center", $fn = 64);
                        } else {
                            square([base_width, base_height], center=true);
                        }
                    }
                    cylinder(h=1, r=base_radius);
                }
            }

            // make the raised text
            color(text_color) linear_extrude(depth) {
                text(string, size = font_size, font = font, halign = "center", valign = "center", $fn = 64);
            }
        }

        // carve out  magnet holes (difference)
        translate([0, 0, 0]) {
            // center or only magnet hole
            cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
            };

            // add two additional magnet holes
            if (base_width + base_radius > single_magnet_width) {
                translate([-base_width/2 + 10, 0, 0]) {
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };

                translate([base_width/2 - 10, 0, 0]) {
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };
            }
    }
}

// SCAD is a functional language, so variables only get set once per function
// so we do things recursively since iterations don't do what one would expect
module makelabels(labels, font, idx = 0) {
    offset = idx * label_y_offset;
    if (idx < len(labels)) {
        if (offset < bed_size[1] - (label_y_offset*2)) {
            makelabel(labels[idx], font, offset);
            makelabels(labels, font, idx + 1);
        } else {
            echo(str("WARNING: Not enough room to print ", labels[idx]));
        }
    }
}
