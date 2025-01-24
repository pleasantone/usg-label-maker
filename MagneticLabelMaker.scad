// Magnetic Label Maker by Pleasant One remixed from Josh
// See documentation for License.


/* [Labels] */
// The labels to print, delimited by "|"
labels = "TEST LABEL|TEST LABEL 2";

/* [Label examples] */
// Some examples of labels, nothing is done with these at this time
example_labels_a = "SAE SOCKETS|RATCHETS|RATCHETS|SCREWDRIVERS|WRENCHES|TORQUE WRENCHES|PLIERS|BIT SETS|POWER TOOLS|ELECTRICAL|PUNCHES|BED SIZE TEST";
example_labels_b = "CHISELS|PICKS|TORX|ALLEN|JUNK|RIVETING|SHEARS|MEASURING|MISC|PPE";
example_labels_c = "MOTORCYCLE|MARKING|MAGNETS|PRY BARS|BRUSHES|CRIMPERS|SOLDERING";
example_labels_d = "HAMMERS|LIGHTS|ZIP TIES|TAPE|DRILL BITS|ADHESIVES|SEALANTS|AUTOMOTIVE TOOLS|OILS|PAINT";

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
font_name = "FONTSPRING DEMO \\- Avionic Wide Oblique Black"; //[,FONTSPRING DEMO \\- Avionic Wide Oblique Black,Harmony OS Sans,Inter,Inter Tight,Lora,Merriweather Sans,Montserrat,Noto Emoji,Noto Sans,Noto Sans Adlam,Noto Sans Adlam Unjoined,Noto Sans Arabic,Noto Sans Arabic UI,Noto Sans Armenian,Noto Sans Balinese,Noto Sans Bamum,Noto Sans Bassa Vah,Noto Sans Bengali,Noto Sans Bengali UI,Noto Sans Canadian Aboriginal,Noto Sans Cham,Noto Sans Cherokee,Noto Sans Devanagari,Noto Sans Display,Noto Sans Ethiopic,Noto Sans Georgian,Noto Sans Gujarati,Noto Sans Gunjala Gondi,Noto Sans Gurmukhi,Noto Sans Gurmukhi UI,Noto Sans HK,Noto Sans Hanifi Rohingya,Noto Sans Hebrew,Noto Sans JP,Noto Sans Javanese,Noto Sans KR,Noto Sans Kannada,Noto Sans Kannada UI,Noto Sans Kawi,Noto Sans Kayah Li,Noto Sans Khmer,Noto Sans Khmer UI,Noto Sans Lao,Noto Sans Lao Looped,Noto Sans Lao UI,Noto Sans Lisu,Noto Sans Malayalam,Noto Sans Malayalam UI,Noto Sans Medefaidrin,Noto Sans Meetei Mayek,Noto Sans Mono,Noto Sans Myanmar,Noto Sans NKo Unjoined,Noto Sans Nag Mundari,Noto Sans New Tai Lue,Noto Sans Ol Chiki,Noto Sans Oriya,Noto Sans SC,Noto Sans Sinhala,Noto Sans Sinhala UI,Noto Sans Sora Sompeng,Noto Sans Sundanese,Noto Sans Symbols,Noto Sans Syriac,Noto Sans Syriac Eastern,Noto Sans TC,Noto Sans Tai Tham,Noto Sans Tamil,Noto Sans Tamil UI,Noto Sans Tangsa,Noto Sans Telugu,Noto Sans Telugu UI,Noto Sans Thaana,Noto Sans Thai,Noto Sans Thai UI,Noto Sans Vithkuqi,Nunito,Nunito Sans,Open Sans,Open Sans Condensed,Oswald,Playfair Display,Plus Jakarta Sans,Raleway,Roboto,Roboto Condensed,Roboto Flex,Roboto Mono,Roboto Serif,Roboto Slab,Rubik,Source Sans 3,Ubuntu Sans,Ubuntu Sans Mono,Work Sans]

//alternatively:
//use <sd prostreet.ttf>
//font_name = "sd prostreet";

// Not all styles may work (ok to leave empty)
font_style = ""; // [,Regular,Bold,Medium,SemiBold,Light,ExtraBold,Black,ExtraLight,Thin,Bold Italic,Italic,Light Italic,Medium Italic]
// Additional font styles listed in order of popularity, many may not work with your selected font_family (ok to leave empty)
advanced_styles = ""; //[,SemiBold Italic,ExtraBold Italic,Black Italic,ExtraLight Italic,Condensed Bold,Condensed ExtraBold,Condensed Light,Condensed SemiBold,Thin Italic,Condensed ExtraLight,Condensed Medium,Condensed Thin,Condensed,Condensed Black,ExtraCondensed,SemiCondensed,ExtraCondensed Black,ExtraCondensed Bold,ExtraCondensed ExtraBold,ExtraCondensed ExtraLight,ExtraCondensed Light,ExtraCondensed Medium,ExtraCondensed SemiBold,ExtraCondensed Thin,SemiCondensed Black,SemiCondensed Bold,SemiCondensed ExtraBold,SemiCondensed ExtraLight,SemiCondensed Light,SemiCondensed Medium,SemiCondensed SemiBold,SemiCondensed Thin,Condensed Bold Italic,Condensed ExtraBold Italic,Condensed Italic,Condensed Light Italic,Condensed SemiBold Italic,Condensed ExtraLight Italic,Condensed Medium Italic,Condensed Regular,Condensed Thin Italic,Condensed Black Italic,12pt ExtraLight,12pt ExtraLight Italic,20pt Italic,20pt Regular,ExtraBlack,ExtraBlack Italic,ExtraCondensed Black Italic,ExtraCondensed Bold Italic,ExtraCondensed ExtraBold Italic,ExtraCondensed ExtraLight Italic,ExtraCondensed Italic,ExtraCondensed Light Italic,ExtraCondensed Medium Italic,ExtraCondensed SemiBold Italic,ExtraCondensed Thin Italic,SemiCondensed Black Italic,SemiCondensed Bold Italic,SemiCondensed ExtraBold Italic,SemiCondensed ExtraLight Italic,SemiCondensed Italic,SemiCondensed Light Italic,SemiCondensed Medium Italic,SemiCondensed SemiBold Italic,SemiCondensed Thin Italic]
// font size in points
font_size = 8; // [5:32]


/* [Base] */
/* If true, base flows with letter shapes, but slower to render
   and can do weird stuff with the letters with descenders (Q)
   or trailing characters with reverse angles (L). It's pretty
   when it works out correctly but off by default to be safe
   for all cases. */

// Is the base a rectangle or does it follow the letter outline?
base_shape = 0; // [0:Rectangle, 1:Outline letters]
// Rounded corner radius (default 2mm, 0 for sharp corners)
base_radius = 2.0;
// Total depth in mm of badge and base in mm (default 5mm)
depth = 5.0;
// Depth of the magnet hole in mm
magnet_depth = 3.75;
// Diameter of the magnet hole in mm
magnet_diameter = 8.0;
// If the piece is less than X mm wide, create only a single magnet hole, otherwise create 3 holes
single_magnet_width = 36;

/* [Preview colors settings (preview only, need to paint in slicer)] */
base_color = "black";
text_color = "white";

/* [Printer and offset settings] */
// distance between labels on plate in mm
label_y_offset = 20.0;
// printer bed size (BambuLab A1/P1/X1 are 255x255x255)
bed_size=[255, 255];

/* [ Hidden ] */
$fn = 32; // Model detail, higher is more detail and more processing

label_group = is_string(labels) ? split("|", labels) : labels;
font = font_style ? str(font_name, ":style=", advanced_styles ? advanced_styles : font_style) : font_name;

for (idx = [0:len(label_group)]) {
    offset = idx * label_y_offset;
    if (idx < len(label_group)) {
        if (offset < bed_size[1] - label_y_offset * 2) {
            make_base(label_group[idx], font, offset);
            make_text(label_group[idx], font, offset);
        } else {
            echo(str("WARNING: Not enough room to print ", label_group[idx]));
        }
    }
}

module make_base(string, font, y_offset = 0) {
    tmetrics = textmetrics(string, size = font_size, font = font, halign = "center", valign = "center", $fn=64);
    base_width = tmetrics["size"][0];
    base_height = tmetrics["size"][1];

    // double-check that a single label won't be too wide
    assert(base_width+base_radius < bed_size[0]);

    // move to the y-offset in case multiple labels are happening
    translate([0, y_offset, 0]) difference() {
        // make the base
        color(base_color)
        difference() {
            hull() { // wrap all words
                minkowski() { // chamfer corners and flow letters
                    linear_extrude(depth/2) {
                        if (base_shape) {
                            text(string, size=font_size, font=font, halign="center", valign="center", $fn = 64);
                        } else {
                            square([base_width, base_height], center=true);
                        }
                    }
                    cylinder(h=1, r=base_radius);
                }
            }
            // carve out center magnet hole (difference)
            translate([0, 0, 0]) {
                // center or only magnet hole
                cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
            };
            // carve out two additional magnet holes if needed
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
}

module make_text(string, font, y_offset = 0) {
    translate([0, y_offset, 0])
    difference() {
        // make the raised text
        color(text_color)
        translate([0, 0, depth/2])
        linear_extrude(depth/2) {
            text(string, size = font_size, font = font, halign = "center", valign = "center", $fn = 64);
        }
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
//        union() {
            // make the base
            color(base_color)
            difference() {
                hull() { // wrap all words
                    minkowski() { // chamfer corners and flow letters
                        linear_extrude(depth/2) {
                            if (base_shape) {
                                text(string, size=font_size, font=font, halign="center", valign="center", $fn = 64);
                            } else {
                                square([base_width, base_height], center=true);
                            }
                        }
                        cylinder(h=1, r=base_radius);
                    }
                }
                // carve out center magnet hole (difference)
                translate([0, 0, 0]) {
                    // center or only magnet hole
                    cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                };
                // carve out two additional magnet holes if needed
                if (base_width + base_radius > single_magnet_width) {
                    translate([-base_width/2 + 10, 0, 0]) {
                        cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                    };

                    translate([base_width/2 - 10, 0, 0]) {
                        cylinder(magnet_depth, magnet_diameter / 2 + 0.2, magnet_diameter / 2 + 0.1, true);
                    };
                }
            }

            // make the raised text
            color(text_color)
            translate([0, 0, depth/2])
            linear_extrude(depth/2) {
                text(string, size = font_size, font = font, halign = "center", valign = "center", $fn = 64);
            }
//        }
    }
}

// extract a substring from a string
// string, start, end, error-return
function substr(s, st, en, p="") =
    (st >= en || st >= len(s))
    ? p
    : substr(s, st+1, en, str(p, s[st]));

// split a string into an array of strings
// delimiter, string
function split(h, s, p=[]) = let(x = search(h, s))
    x == []
    ? concat(p, s)
    : let(i=x[0], l=substr(s, 0, i), r=substr(s, i+1, len(s)))
    split(h, r, concat(p, l));
