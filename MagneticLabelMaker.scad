/*
  Magnetic Label Maker by Pleasant One remixed from Josh
  See documentation for License.
  
  We have two similar but different working environments, OpenSCAD locally or
  online with a customizer like Makerworld's Parametric Model Maker
  
  With MakerWorld's product, we can support up to five plates of
  labels to be generated at once. MakerWorld's extensions allow for
  encoding color information in the .3mf.

  However, MakerWorld cannot add user fonts, so we can't get the
  closest US General matching font.  I have found that MakerWorld's
  Montserrat Extra Bold Italic is moderately close.

  With OpenSCAD locally, we only support producing one (the first)
  plate at a time.  You can generate either .STL files or .3MFs but
  no color information will be encoded.  The output file will contain
  two object parts, the base of and the text.  Load both parts
  together using your slicer, and then use your slicer to assign
  color information.
*/

// Are we running on MakerWorld or a local instance of OpenSCAD?
MakerWorld_Customizer_Environment = true;

// The labels to print, delimited by "|"
plate_labels_1 = "METRIC SOCKETS|SAE SOCKETS|SPECIALTY SOCKETS|RATCHETS|SCREWDRIVERS|WRENCHES|TORQUE WRENCHES|PLIERS|BIT SETS|POWER TOOLS|ELECTRICAL|CHISELS|PICKS|TORX|ALLEN|JUNK|RIVETING";

// Multiple plate support only works on MakerWorld
plate_labels_2 = "SHEARS|MEASURING|MISC|PPE|MOTORCYCLE|MARKING|MAGNETS|PRY BARS|BRUSHES|CRIMPERS|SOLDERING|HAMMERS|LIGHTS|ZIP TIES|TAPE|DRILL BITS|ADHESIVES|SEALANTS";
plate_labels_3 = "AUTOMOTIVE TOOLS|OILS|PAINT|BRAKE TOOLS|HAMMERS|SAE WRENCHES|METRIC WRENCHES|VISE GRIPS|AIR TOOLS|POWER TOOLS|SNACKS|ELECTRICAL TOOLS|ELECTRICAL DIAGNOSTICS|ALLEN|TORX|HARDWARE";
plate_labels_4 = "EXTENSIONS|BREAKER BARS|HEX KEYS|SAE|METRIC|SOCKETS|ELECTRICAL|NO TOUCH|BITS|IMPACT WRENCHES|1/4\" RATCHETS|3/8\" RATCHETS|1/2\" RATCHETS|I WASN'T ASKING TOOL";
plate_labels_5 = "DON'T TOUCH MY TOOLS";

/* A note on fonts:

   If you are intending to match the US General font, it is non-standard
   and is not installed on either OpenSCAD or with MakerWorld. You will need
   to download a closely matching font.
   
   The best font available on MakerWorld is Montserrat Extra Bold Italic.

   For local operation, where you can use any font you find on the web,
   Avionic Wide Oblique Black is quite close to the USG font, but any of
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

// best local OpenSCAD fonts
// font = "FONTSPRING DEMO \\- Avionic Wide Oblique Black"; // font
// font = "sd prostreet"; // font

// best MakerWorld font is Montserrat ExtraBold Italic
font = "Montserrat:style=ExtraBold Italic"; //font

// Font size in points
font_size = 8; // [5:32]

/* [Colors] */
// Base color
base_color = "#000000"; // color

// Text color
text_color = "#FFFFFF"; // color

/* [Details] */
/*
   If base_outline is true, the base will flow with letter shapes. It is slower
   to render and could be unaesthetic when using letters with descenders
   (Q) or trailing characters with reverse angles (L). It's very pretty
   when it works out correctly but, to be safe, we leave this off by default.
*/

// Should the base follow an outline of the letters? (see notes!)
base_outline = 0; // [0: Standard base, 1: Follow letter shapes]

// Rounded corner radius in mm (default 2mm)
base_radius = 2; // [1:10]

// Total depth in mm of badge and base in mm (default 5mm)
depth = 5;

// Diameter of the magnet hole in mm
magnet_diameter = 8;

// Depth of the magnet hole in mm
magnet_depth = 3;

// Fully encapsulated magnets or open at the base. If encapsulate, pause the print at the top of the hole to insert magnets
encapsulate_magnets = false;

/* [Printer dimensions] */
// printer bed size (BambuLab A1/P1/X1 are approximately 255mmx255mm)
bed_size=[255, 255];

/* [Advanced] */
magnet_depth_clearance = 0.1; // Depth clearance for magnet
magnet_cylinder_top_clearance = 0.1; // Top of magnet cutout clearnace
magnet_cylinder_bottom_clearance = 0.2; // Bottom of magnet cutout clearance
magnet_depth_offset = encapsulate_magnets ? magnet_depth_clearance * 2 : 0;

magnet_hole_bore = magnet_depth + magnet_depth_clearance;
magnet_hole_top = magnet_hole_bore + magnet_depth_offset;

// If the piece is less than X mm wide, create only a single magnet hole, otherwise create 3 holes
single_magnet_width = 36;

// Extra Y gap between labels in case they smush together
label_y_extra_spacing = 0;

/* [ Hidden ] */

base_depth = magnet_hole_top + (magnet_depth_clearance*2);

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
module mw_plate_5(labels=plate_labels_5) mw_make_labels(labels);

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

if (!MakerWorld_Customizer_Environment) {
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
        y_start = (bed_size.y / -2) + offset * index;
        assert(y_start < (bed_size.y / 2 - offset * 2),
               str("ERROR: Not enough Y-axis plate space to print " , label, "--decrease label count or font size"));
        translate([0, y_start, 0]) let($string = label) children();
    }
}

// calculate the maximum height of any of our labels
function gap(label_group) =
    max([for(label = label_group) label_len_y(label)]) + base_radius;

// the y length of a label
function label_len_y(string) =
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
           str("ERROR: Not enough X-axis plate space to print ", string, ", decrease label length or font size"));

    // make the base
    difference() {
        hull() // wrap all words
            minkowski() { // chamfer corners and flow letters
                linear_extrude(base_depth, center=false) {
                    if (base_outline)
                        text(string, size=font_size, font=font,
                             halign="center", valign="center", $fn = 64);
                    else
                        square([base_width, base_height], center=true);
                }
                cylinder(h=1, r=base_radius);
            }

        // cut out center magnet hole (difference)
        translate([0, 0, magnet_depth_offset]) cut_magnet();
        // cut out two additional magnet holes if needed
        if (base_width + base_radius > single_magnet_width) {
            translate([-base_width/2 + 10, 0, magnet_depth_offset]) cut_magnet();
            translate([base_width/2 - 10, 0, magnet_depth_offset]) cut_magnet();
        }
    }
}

module cut_magnet() {
    cylinder(magnet_hole_bore,
             magnet_diameter / 2 + magnet_cylinder_bottom_clearance,
             magnet_diameter / 2 + magnet_cylinder_top_clearance,
             center=false);
}

// Make the text part of an object -- will position on top of base.
module make_text(string = $string) {
    translate([0, 0, base_depth])
        linear_extrude(depth - base_depth, center=false)
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
