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
/* Avionic Wide Oblique Black is quite close to the "U.S. GENERAL"
   font that Harbor Freight uses, but pick your favorite.

   These are all close:
   https://demofont.com/avionic-sans-serif-font/
   https://www.ffonts.net/sdprostreet-Regular.font
   https://www.ffonts.net/Concielian-Bold-Semi-Italic.font

   There are two ways to install private fonts, the easiest
   is to install it in your system. The other way is to add
   use </path/to/font/file.ttf> to this file and then set
   the font name as in:

   use <sd prostreet.ttf>
   font = "sd prostreet";

   You might need to restart OpenSCAD in order for it to recognize
   newly installed or "used' fonts.
*/

//use <Avionic Font/Fontspring-DEMO-avionicwideoblique-black.otf>

// Text font
font = "FONTSPRING DEMO \\- Avionic Wide Oblique Black"; // font

// font size in points
font_size = 8; // [5:32]


/* [Base] */
/*
   If true, base flows with letter shapes, but slower to render
   and can do weird stuff with the letters with descenders (Q)
   or trailing characters with reverse angles (L). It's pretty
   when it works out correctly but off by default to be safe
   for all cases.
*/

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

/*
 If we are using the development snapshot with the lazy_union
 enabled, and we export this as a .3MF file, each "top level"
 creation will be its own object. This is an easy way to handle
 color changes.  Import the .3mf file into your slicer, click "Yes"
 when it asks to bring in multiple objects as parts of one single
 object, and it will position each part correctly. Then go into
 object menu and set part number two to your base color.
*/

color(base_color)
    iterate_labels()
        make_base(); // all the bases will export as a single object

color(text_color)
    iterate_labels()
        make_text(); // all the text will export as a single object

module iterate_labels() {
    for (idx = [0:len(label_group)-1]) {
        offset = idx * label_y_offset;
        if (offset < bed_size[1] - label_y_offset * 2)
            translate([0, offset, 0])
                let ($string = label_group[idx])
                    children();
        else
            echo(str("WARNING: Not enough room to print ", label_group[idx]));
    }
}

module make_base(string=$string) {
    tmetrics = textmetrics(string, size = font_size, font = font,
                           halign = "center", valign = "center", $fn=64);
    base_width = tmetrics["size"][0];
    base_height = tmetrics["size"][1];

    // double-check that a single label won't be too wide
    assert(base_width + base_radius < bed_size[0]);

    // make the base
    difference() {
        hull() // wrap all words
            minkowski() { // chamfer corners and flow letters
                linear_extrude(depth/2) {
                    if (base_shape)
                        text(string, size=font_size, font=font,
                             halign="center", valign="center", $fn = 64);
                    else
                        square([base_width, base_height], center=true);
                }
                cylinder(h=1, r=base_radius);
            }

        // carve out center magnet hole (difference)
        translate([0, 0, 0])
            cylinder(magnet_depth, magnet_diameter / 2 + 0.2,
                                   magnet_diameter / 2 + 0.1, true);

        // carve out two additional magnet holes if needed
        if (base_width + base_radius > single_magnet_width) {
            translate([-base_width/2 + 10, 0, 0])
                cylinder(magnet_depth, magnet_diameter / 2 + 0.2,
                                       magnet_diameter / 2 + 0.1, true);
            translate([base_width/2 - 10, 0, 0])
                cylinder(magnet_depth, magnet_diameter / 2 + 0.2,
                                       magnet_diameter / 2 + 0.1, true);
        }
    }
}

module make_text(string=$string) {
    translate([0, 0, (depth/2)+1.0])
        linear_extrude(depth/2)
            text(string, size = font_size, font = font,
                 halign = "center", valign = "center", $fn = 64);
}

// extract a substring from a string
// parameters: string, start, end, if-error-return-string
function substr(s, st, en, p="") =
    (st >= en || st >= len(s))
    ? p
    : substr(s, st+1, en, str(p, s[st]));

// split a string into an array of strings
// parameters: delimiter, string
function split(h, s, p=[]) = let(x = search(h, s))
    x == []
    ? concat(p, s)
    : let(i=x[0], l=substr(s, 0, i), r=substr(s, i+1, len(s)))
        split(h, r, concat(p, l));
