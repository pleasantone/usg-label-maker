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
   the default is sd prostreet. Avionic Wide Oblique Black is the closest
   match to the actual USG font but is only available as a Fontspring demo
   download -- use it as a backup if you want the closer look. Any of these
   work well:

   https://www.ffonts.net/sdprostreet-Regular.font     (default)
   https://demofont.com/avionic-sans-serif-font/       (backup: closest USG match, demo license)
   https://www.ffonts.net/Concielian-Bold-Semi-Italic.font  (backup)

   Download one or more of them and unpack.
   Install the downloaded font(s) to your system. (On a Mac, double-click the .ttf and install.)

   You might need to restart OpenSCAD in order for it to recognize
   newly installed or "used' fonts.

   The sample pictures were taken with Avionic Wide Oblique Black's demo.
*/

// Default font follows the environment: Montserrat on MakerWorld (only fonts in
// their library are available), sd prostreet locally. Override in the customizer
// or via OpenSCAD -D for batch runs.
// Backup local options:
//   "FONTSPRING DEMO \\- Avionic Wide Oblique Black" -- closest USG match (demo license)
//   "Concielian:style=Bold Semi Italic"
font = MakerWorld_Customizer_Environment
    ? "Montserrat:style=ExtraBold Italic"
    : "sd prostreet"; //font

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

// Rounded corner radius in mm
base_radius = 2;

// Total depth in mm of badge and base in mm
depth = 5;

// Diameter of the magnet hole in mm
magnet_diameter = 8;

// Depth of the magnet hole in mm
magnet_depth = 3;

// Fully encapsulated magnets or open at the base. If encapsulate, pause the print at the top of the hole to insert magnets
encapsulate_magnets = false;

// place magnet holes in mm from inside edge
magnet_edge_inboard = 10;

// minimum separation in mm between outer holes before dropping to one hole
magnet_minimum_separation = 2;

// if piece is >mm wide, add a center hole
magnet_center_hole_width = 60;

/* [Printer dimensions] */
// printer bed size (BambuLab A1/P1/X1 are approximately 255mmx255mm)
bed_size=[255, 255];

/* [Advanced] */
// Extra padding for magnet cut on Z axis
magnet_depth_clearance = 0.1;
// Extra padding for magnet at top of cut
magnet_topcyl_clearance = 0.1;
// Extra padding for magnet at bottom of cut
magnet_bottomcyl_clearance = 0.2;

// lower Z bounds of magnet cut
magnet_depth_offset = encapsulate_magnets ? magnet_depth_clearance * 2 : 0;
magnet_hole_bore = magnet_depth + magnet_depth_clearance;
magnet_hole_top = magnet_hole_bore + magnet_depth_offset;
// the .1 is slop so we can get enough material around the magnet
magnet_wrap_diameter = magnet_diameter + magnet_bottomcyl_clearance; // + 0.042;

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
    color(base_color) iterate_labels(labels) make_base();
    color(text_color) iterate_labels(labels) make_text();
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

// Split + clean the label list, precompute textmetrics once per label, then
// stamp out each child with $string and $tmetrics bound so make_base/make_text
// can reuse the same metrics without re-measuring.
module iterate_labels(labels) {
    raw = is_string(labels) ? split("|", labels) : labels;
    label_group = [for (l = raw) if (len(l) > 0) l];

    if (len(label_group) > 0) {
        all_metrics = [
            for (l = label_group)
                textmetrics(l, size = font_size, font = font,
                            halign = "center", valign = "center")
        ];
        slot = max([
            for (m = all_metrics)
                ceil(max(magnet_wrap_diameter, m["size"][1]) + base_radius)
        ]) + label_y_extra_spacing;

        for (index = [0 : len(label_group) - 1]) {
            label = label_group[index];
            // center labels inside their Y-axis slot, stacked from -Y to +Y
            y_center = -bed_size.y / 2 + slot * (index + 0.5);
            assert(y_center + slot / 2 <= bed_size.y / 2,
                   str("ERROR: Not enough Y-axis plate space to print ", label,
                       " -- decrease label count or font size"));
            translate([0, y_center, 0])
                let($string = label, $tmetrics = all_metrics[index])
                    children();
        }
    }
}

// $string and $tmetrics are bound by iterate_labels — defaulted here so the
// modules can also be called standalone for debugging.
module make_base(string = $string, tmetrics = $tmetrics) {
    base_width = tmetrics["size"][0];
    base_height = max(tmetrics["size"][1], magnet_wrap_diameter);

    // minkowski with a cylinder of base_radius adds base_radius on every side,
    // so the actual base extends base_width + 2*base_radius on X.
    assert(base_width + 2 * base_radius < bed_size.x,
           str("ERROR: Not enough X-axis plate space to print ", string,
               " -- decrease label length or font size"));

    difference() {
        hull() // wrap all letter glyphs into a single envelope
            minkowski() { // chamfer corners (and flow letters when base_outline)
                linear_extrude(base_depth, center = false) {
                    if (base_outline)
                        text(string, size = font_size, font = font,
                             halign = "center", valign = "center");
                    else
                        square([base_width, base_height], center = true);
                }
                cylinder(h = 1, r = base_radius);
            }
        place_magnet_holes(base_width);
    }
}

// Drills magnet pockets out of the base. Two end holes when there's room for
// them, otherwise a single center hole; a third center hole is added on wide
// labels when the end holes leave a comfortable middle gap.
module place_magnet_holes(base_width) {
    magnet_outer_radius = magnet_diameter / 2 + magnet_bottomcyl_clearance;
    // actual gap between the outer edges of the two end holes
    magnet_gap = base_width - 2 * magnet_edge_inboard - 2 * magnet_outer_radius;

    if (magnet_gap > magnet_minimum_separation) {
        translate([-base_width / 2 + magnet_edge_inboard, 0, magnet_depth_offset]) cut_magnet();
        translate([ base_width / 2 - magnet_edge_inboard, 0, magnet_depth_offset]) cut_magnet();
        if (base_width > magnet_center_hole_width &&
            magnet_gap > magnet_minimum_separation * 4) {
            translate([0, 0, magnet_depth_offset]) cut_magnet();
        }
    } else {
        translate([0, 0, magnet_depth_offset]) cut_magnet();
    }
}

// Slightly tapered cylinder: wider at the bottom (bottomcyl_clearance) than the
// top (topcyl_clearance) so a magnet dropped in from the open base seats firmly
// against the cap. Do not "fix" by swapping — direction is intentional.
module cut_magnet() {
    cylinder(h = magnet_hole_bore,
             r1 = magnet_diameter / 2 + magnet_bottomcyl_clearance,
             r2 = magnet_diameter / 2 + magnet_topcyl_clearance,
             center = false,
             $fn = 64);
}

// Make the text part of an object -- will position on top of base.
module make_text(string = $string) {
    assert(depth > base_depth,
           str("ERROR: depth (", depth, "mm) must exceed base_depth (",
               base_depth, "mm) so raised text has positive height. ",
               "Increase depth or reduce magnet_depth."));
    translate([0, 0, base_depth])
        linear_extrude(depth - base_depth, center = false)
            text(string, size = font_size, font = font,
                 halign = "center", valign = "center");
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
