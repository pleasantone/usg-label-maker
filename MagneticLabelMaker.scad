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

plate_labels = str(plate_labels_1, "|", plate_labels_2, "|", plate_labels_3, "|", plate_labels_4, "|", plate_labels_5);

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

// Wall width in mm of the preview-only plate-edge border (never exported)
border_thickness = 3;

/* [Exclusion zones] */
// Skip rectangular keep-out areas when arranging labels (each anchored to a bed
// corner). Sizes are [width, height] in mm.

// Zone 1 default: Bambu X1C front-left cutter / nozzle-wipe area (tune to taste)
exclude_zone_1 = true;
exclude_zone_1_corner = "left-bottom"; // [left-bottom, right-bottom, left-top, right-top]
exclude_zone_1_size = [18, 18];

// Zone 2 default: space reserved for a prime / purge tower
exclude_zone_2 = true;
exclude_zone_2_corner = "right-top"; // [left-bottom, right-bottom, left-top, right-top]
exclude_zone_2_size = [100, 100];

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

// Safety gap in mm between neighbouring label footprints (applied on both axes)
label_gap = 1;

/* [ Hidden ] */

base_depth = magnet_hole_top + (magnet_depth_clearance*2);

// Active exclusion zones as rectangles [x_min, y_min, x_max, y_max] in the same
// bed-centered coordinate system the labels are placed in.
exclusion_zones = concat(
    exclude_zone_1 ? [corner_rect(exclude_zone_1_corner, exclude_zone_1_size, bed_size)] : [],
    exclude_zone_2 ? [corner_rect(exclude_zone_2_corner, exclude_zone_2_size, bed_size)] : []
);

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
        iterate_labels(plate_labels)
            make_base(); // all the bases will export as a single object

    color(text_color)
         iterate_labels(plate_labels)
            make_text(); // all the text will export as a single object
}

// Reference frame around the bed edges plus the exclusion-zone overlays.
// $preview is true only for on-screen preview (F5); it is false during full
// render and every export (F6, CLI -o, MakerWorld), so these never become part
// of any STL/3MF.
if ($preview) {
    plate_border();
    plate_exclusions();
}


/* ------------------------ */

// Pack labels onto the plate, routing around any exclusion zones. Measure each
// label once, derive a uniform row height (slot) from the tallest footprint, lay
// a centered grid of row-bands across the bed, carve each band into the free
// X-intervals left between the exclusion zones ("shelves"), then bin-pack
// widest-first into those shelves (first-fit decreasing). $string and $tmetrics
// are bound per label so make_base/make_text never re-measure.
module iterate_labels(labels) {
    raw = is_string(labels) ? split("|", labels) : labels;
    label_group = [for (l = raw) if (len(l) > 0) l];

    if (len(label_group) > 0) {
        metrics = [
            for (l = label_group)
                textmetrics(l, size = font_size, font = font,
                            halign = "center", valign = "center")
        ];

        // minkowski adds base_radius on every side, so the real footprint is the
        // text box grown by 2*base_radius in each axis; label_gap then keeps
        // neighbouring bases from fusing on the plate.
        widths  = [for (m = metrics) m["size"][0] + 2 * base_radius];
        heights = [for (m = metrics)
                       max(magnet_wrap_diameter, m["size"][1]) + 2 * base_radius];
        slot = max(heights) + label_gap;

        W = bed_size.x;
        H = bed_size.y;
        band_count = floor(H / slot);

        // zones grown by label_gap so labels keep clear of the keep-out areas
        zinf = [for (z = exclusion_zones) inflate(z, label_gap)];

        // centered grid of row-bands; each band carved into free X-intervals.
        // shelf = [x_min, x_max, y_center]
        shelves = [
            for (r = [0 : band_count - 1])
                let(yhi   = band_count * slot / 2 - r * slot,
                    ylo   = yhi - slot,
                    yc    = yhi - slot / 2,
                    frees = free_intervals(-W/2, W/2, band_blockers(zinf, ylo, yhi)))
                each [for (iv = frees) if (iv[1] - iv[0] > 0) [iv[0], iv[1], yc]]
        ];

        // widest-first first-fit-decreasing across the shelves
        order = sorted_desc(widths);
        ord_widths = [for (i = order) widths[i]];
        packed = pack_shelves(ord_widths, shelves, label_gap);
        places = packed[0];   // [shelf, x_left] per item; shelf == -1 if unplaced
        used   = packed[1];   // consumed width of each shelf

        unplaced = [for (k = [0 : len(order) - 1])
                        if (places[k][0] < 0) label_group[order[k]]];
        assert(len(unplaced) == 0,
               str("ERROR: no plate space for ", unplaced,
                   " -- decrease label count or font size, shrink the exclusion ",
                   "zones, or split across plates"));

        for (k = [0 : len(order) - 1]) {
            s   = places[k][0];
            idx = order[k];
            w   = ord_widths[k];
            free_w = shelves[s][1] - shelves[s][0];
            // centre each shelf's run of labels within its free interval
            x = shelves[s][0] + (free_w - used[s]) / 2 + places[k][1] + w / 2;
            y = shelves[s][2];

            translate([x, y, 0])
                let($string = label_group[idx], $tmetrics = metrics[idx])
                    children();
        }
    }
}

/* ---- Exclusion-aware shelf bin-packing (first-fit decreasing) ----------- */

// Rectangle [x_min, y_min, x_max, y_max] for a zone anchored to a bed corner.
function corner_rect(corner, size, bed) =
    let(w = size[0], h = size[1], W = bed[0], H = bed[1],
        left   = (corner == "left-bottom"  || corner == "left-top"),
        bottom = (corner == "left-bottom"  || corner == "right-bottom"),
        x = left   ? -W/2 : W/2 - w,
        y = bottom ? -H/2 : H/2 - h)
    [x, y, x + w, y + h];

// Grow a zone rect by clearance c on every side.
function inflate(z, c) = [z[0] - c, z[1] - c, z[2] + c, z[3] + c];

// X-ranges [lo, hi] of the zones that intrude on the Y band [ylo, yhi].
function band_blockers(zones, ylo, yhi) =
    [for (z = zones) if (z[1] < yhi && z[3] > ylo) [z[0], z[2]]];

// Free sub-intervals of [a, b] left after removing the blocker X-ranges.
function free_intervals(a, b, blockers) = sweep(a, b, sort_by_lo(blockers));

function sweep(cur, b, bs, i = 0, acc = []) =
    i >= len(bs) || bs[i][0] >= b
        ? (cur < b ? concat(acc, [[cur, b]]) : acc)
        : let(seg  = bs[i][0] > cur ? [[cur, bs[i][0]]] : [],
              ncur = max(cur, bs[i][1]))
          sweep(ncur, b, bs, i + 1, concat(acc, seg));

// Selection sort of [lo, hi] ranges by lo ascending (few zones => O(n^2) fine).
function sort_by_lo(v, rem = undef, acc = []) =
    let(r = is_undef(rem) ? [for (i = [0 : len(v) - 1]) i] : rem)
    len(r) == 0 ? acc :
    let(b = min_lo_index(v, r),
        rest = [for (j = [0 : len(r) - 1]) if (j != b) r[j]])
    sort_by_lo(v, rest, concat(acc, [v[r[b]]]));

function min_lo_index(v, rem, i = 0, bi = 0) =
    i >= len(rem) ? bi
    : min_lo_index(v, rem, i + 1, v[rem[i]][0] < v[rem[bi]][0] ? i : bi);

// Indices of `w` ordered by descending value (selection sort; small counts).
function sorted_desc(w, rem = undef, acc = []) =
    let(r = is_undef(rem) ? [for (i = [0 : len(w) - 1]) i] : rem)
    len(r) == 0 ? acc :
    let(b = max_index(w, r),
        chosen = r[b],
        rest = [for (j = [0 : len(r) - 1]) if (j != b) r[j]])
    sorted_desc(w, rest, concat(acc, [chosen]));

// Position within `rem` of the entry indexing the largest width in `w`.
function max_index(w, rem, i = 0, bi = 0) =
    i >= len(rem) ? bi
    : max_index(w, rem, i + 1, w[rem[i]] > w[rem[bi]] ? i : bi);

// Copy of vector `v` with element `i` replaced by `x`.
function vec_set(v, i, x) = [for (j = [0 : len(v) - 1]) j == i ? x : v[j]];

// First shelf that can still take width `w` (with a leading gap), or
// len(shelves) to signal "doesn't fit anywhere".
function fit_shelf(shelves, used, w, gap, s = 0) =
    s >= len(shelves) ? s :
    let(free_w = shelves[s][1] - shelves[s][0], u = used[s],
        ok = u == 0 ? w <= free_w : u + gap + w <= free_w)
    ok ? s : fit_shelf(shelves, used, w, gap, s + 1);

// Greedy FFD packer over shelves. Returns [places, used]:
//   places[k] = [shelf, x_left] for the k-th (width-sorted) item; shelf == -1
//               when it didn't fit any shelf
//   used[s]   = total consumed width of shelf s (widths + internal gaps)
function pack_shelves(widths, shelves, gap, i = 0, used = undef, places = []) =
    let(u = is_undef(used) ? [for (s = shelves) 0] : used)
    i >= len(widths) ? [places, u] :
    let(w = widths[i],
        s = fit_shelf(shelves, u, w, gap),
        hit = s < len(shelves),
        x_left = !hit ? 0 : (u[s] == 0 ? 0 : u[s] + gap),
        u2 = hit ? vec_set(u, s, x_left + w) : u,
        rec = hit ? [s, x_left] : [-1, 0])
    pack_shelves(widths, shelves, gap, i + 1, u2, concat(places, [rec]));

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

// Square ring hugging the bed edges, centered on the origin like the labels.
// Preview-only reference (see the $preview guard at top level) -- excluded from
// exports, so it carries no magnet pockets and matches the base height only as a
// visual cue.
module plate_border() {
    color(base_color)
        linear_extrude(base_depth, center = false)
            difference() {
                square(bed_size, center = true);
                square([bed_size.x - 2 * border_thickness,
                        bed_size.y - 2 * border_thickness], center = true);
            }
}

// Preview-only overlays of the exclusion zones (see the $preview guard at top
// level) so the keep-out areas are visible while arranging labels. Translucent
// red, drawn at base height; excluded from every export.
module plate_exclusions() {
    for (z = exclusion_zones)
        color([0.85, 0.12, 0.12, 0.35])
            translate([z[0], z[1], 0])
                linear_extrude(base_depth)
                    square([z[2] - z[0], z[3] - z[1]]);
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
