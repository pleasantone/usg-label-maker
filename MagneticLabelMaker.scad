/*
  Magnetic Label Maker by Pleasant One remixed from Josh
  See documentation for License.
  
  We have two similar but different working environments, OpenSCAD locally or
  online with a customizer like Makerworld's Parametric Model Maker
  
  With Makerworld's product, we can support up to four plates of labels to be
  generated at once. Makerworld's extensions allow for encoding color information
  in the .3mf. 
  
  Additionally, Makerworld cannot add fonts, so we can't get the exact US General matching font.
  I have found that Montserrat Extra Bold Italic is moderately close.
  
  With OpenSCAD locally, we only support producing one (the first) plate at a time.
  You can generate either .STL files or .3MFs but no color information will be encoded.
  The output file will contain two object parts, the base of and the text.
  Load both parts together using your slicer, and then use your slicer to assign color information.
*/

// Are we running on a local instance of OpenSCAD or the MakerWorld customer?
// local_openscad = 0; // [0:MakerWorld Customizer, 1:Local OpenSCAD]

// The labels to print, delimited by "|"
plate_labels_1 = "SAE SOCKETS|RATCHETS|SCREWDRIVERS|WRENCHES|TORQUE WRENCHES|PLIERS|BIT SETS|POWER TOOLS|ELECTRICAL";
// Multiple plate support only works on Makerworld
plate_labels_2 = "CHISELS|PICKS|TORX|ALLEN|JUNK|RIVETING|SHEARS|MEASURING|MISC|PPE";
plate_labels_3 = "MOTORCYCLE|MARKING|MAGNETS|PRY BARS|BRUSHES|CRIMPERS|SOLDIERING";
plate_labels_4 = "HAMMERS|LIGHTS|ZIP TIES|TAPE|DRILL BITS|ADHESIVES|SEALANTS|AUTOMOTIVE TOOLS|OILS|PAINT";

/* A note on fonts:

   If you are intending to match the US General font, it is non-standard
   and is not installed on either OpenSCAD or with Makerworld. You will need
   to download a closely matching font.
   
   The best font available on Makerworld is Montserrat Extra Bold Italic.

   For local operation, where you can use any font you find on the web,
   Avionic Wide Oblique Black is quite close to the USG font, any of
   these are close:

   https://demofont.com/avionic-sans-serif-font/
   https://www.ffonts.net/sdprostreet-Regular.font
   https://www.ffonts.net/Concielian-Bold-Semi-Italic.font

   Download one or more of them and unpack.
   Install the downloaded font(s) to your system. (On a Mac, double-click the .ttf and install.)

   You might need to restart OpenSCAD in order for it to recognize
   newly installed or "used' fonts.

   I used Avionic Wide Oblique Black's demo in the pictures.
*/

// best local OpenSCAD font
// font = "FONTSPRING DEMO \\- Avionic Wide Oblique Black"; // font

// best Makerworld font is Montserrat ExtraBold Italic
font = "Montserrat:style=ExtraBold Italic"; //font

// Font size in points
font_size = 8; // [5:32]

/* [Colors] */
// Base color
base_color = "#000000"; // color

// Text color
text_color = "#FFFFFF"; // color

/* [Advanced: Base Details] */
/*
   If base_outline is true, the base will flow with letter shapes. It is slower
   to render and could be unaesthetic when using letters with descenders
   (Q) or trailing characters with reverse angles (L). It's very pretty
   when it works out correctly but, to be safe, we leave this off by default.
*/

// Should the base follow an outline of the letters? (see notes!)
base_outline = 0; // [0: Standard Base, 1: Follow letter shapes]

// Rounded corner radius in mm (default 2mm)
base_radius = 2; // [1:10]

// Total depth in mm of badge and base in mm (default 5mm)
depth = 5;

// Diameter of the magnet hole in mm
magnet_diameter = 8;

// Depth of the magnet hole in mm
magnet_depth = 3;

// Used for encapsulating magnets
magnet_z_offset = 0; // 0 is open bottom (default)

// If the piece is less than X mm wide, create only a single magnet hole, otherwise create 3 holes
single_magnet_width = 36;

// Extra Y gap between labels in case they smush together
label_y_extra_spacing = 0; // [0:10]

/* [Advanced: Printer settings] */
// printer bed size (BambuLab A1/P1/X1 are 255x255)
bed_size=[255, 255];

/* [ Hidden ] */
makerworld_version = [2024, 12, 31];
local_openscad = version() != makerworld_version;

$fn = 32; // Model detail, higher is more detail and more processing

/* -------------------------------------------------------------------------- */

/* Maker World Multi-plate
   The following modules will only be executed when using the
   Parametric Model Maker.
   
   We define specific modules for each plate.
   
   The name of module should be in syntax: mw_plate_1(), mw_plate_2(), etc.
*/

module mw_plate_1(labels=plate_labels_1) mw_make_labels(labels);
module mw_plate_2(labels=plate_labels_2) mw_make_labels(labels);
module mw_plate_3(labels=plate_labels_3) mw_make_labels(labels);
module mw_plate_4(labels=plate_labels_4) mw_make_labels(labels);

module mw_make_labels(labels) {
    if (len(labels)) {
        color(base_color) iterate_labels(labels) make_base();
        color(text_color) iterate_labels(labels) make_text();
    }
}

/* Local OpenSCAD:

   If we are using the development snapshot of OpenSCAD with the lazy_union
   enabled, each "top level" creation will be its own object part.
   This is an easy way to handle color changes.
   
   Import the .3mf file into your slicer, click "Yes" when it asks to
   bring in multiple objects as parts of one single object, and it will
   position each part correctly.
   
   Then go into the object menu and set filaments as you want them colored.
*/

if (local_openscad) {
    color(base_color)
        iterate_labels(plate_labels_1)
            make_base(); // all the bases will export as a single object

    color(text_color)
         iterate_labels(plate_labels_1)
            make_text(); // all the text will export as a single object
}


/* ------------------------ */

module iterate_labels(labels) {
    label_group = is_string(labels) ? split("|", labels) : labels;
    offset = gap(label_group) + label_y_extra_spacing;

    for (index = [0: len(label_group)-1]) {
        label = label_group[index];
        y_start = offset * index;
        assert(y_start < (bed_size.y - offset * 2),
               str("ERROR: Not enough Y-axis plate space to print ", label, " --decrease label count or font size"));
        translate([0, y_start, 0]) let($string = label) children();
    }
}

// calculate the maximum height of any of our labels
function gap(label_group) =
    max([for(label = label_group) label_height(label)]) + base_radius;

// the height of a label
function label_height(string) =
    ceil(textmetrics(string, size = font_size, font = font,
         halign = "center", valign = "center", $fn = 64)["size"][1]) +
         base_radius;

// make the base part of an object
module make_base(string = $string) {
    tmetrics = textmetrics(string, size = font_size, font = font,
                           halign = "center", valign = "center", $fn=64);
    base_width = tmetrics["size"][0];
    base_height = tmetrics["size"][1];

    assert(base_width + base_radius < bed_size.x,
           str("ERROR: Not enough X-axis plate space to print ", string, " --decrease label length or font size"));

    // make the base
    difference() {
        hull() // wrap all words
            minkowski() { // chamfer corners and flow letters
                linear_extrude(depth/2, center=false) {
                    if (base_outline)
                        text(string, size=font_size, font=font,
                             halign="center", valign="center", $fn = 64);
                    else
                        square([base_width, base_height], center=true);
                }
                cylinder(h=1, r=base_radius);
            }

        // carve out center magnet hole (difference)
        translate([0, 0, magnet_z_offset])
            cylinder(magnet_depth, magnet_diameter / 2 + 0.2,
                                   magnet_diameter / 2 + 0.1, center=false);

        // carve out two additional magnet holes if needed
        if (base_width + base_radius > single_magnet_width) {
            translate([-base_width/2 + 10, 0, magnet_z_offset])
                cylinder(magnet_depth, magnet_diameter / 2 + 0.2,
                                       magnet_diameter / 2 + 0.1, center=false);
            translate([base_width/2 - 10, 0, magnet_z_offset])
                cylinder(magnet_depth, magnet_diameter / 2 + 0.2,
                                       magnet_diameter / 2 + 0.1, center=false);
        }
    }
}

// Make the text part of an object -- will position on top of base.
module make_text(string = $string) {
    translate([0, 0, ceil(depth/2)])
        linear_extrude(depth/2, center=false)
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
