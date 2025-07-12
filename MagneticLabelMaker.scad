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

/* [Internal or Open Holes] */
// Are the holes open in the bottom, or are they hidden inside? For Hidden holes, tell the slicer to pause the print so you can insert the magnets.  
hole_type = 0; // [0: Open Holes in bottom, 1: Hidden holes] 

// If you specify hidden holes, this is the number of layers that will be printed before the holes
bottom_layers=2; 

/* [Base] */
/*
   If true, base flows with letter shapes, but slower to render
   and can do weird stuff with the letters with descenders (Q)
   or trailing characters with reverse angles (L). It's pretty
   when it works out correctly but off by default to be safe
   for all cases.
*/

// Is the base a rectangle or does it follow the letter outline? Outline usually looks great but sometimes goes wrong, so check before printing.
base_shape = 0; // [0:Rectangle, 1:Outline letters]
// Rounded corner radius (default 2mm, 0 for sharp corners)
base_radius = 2;
// Total depth in mm of badge and base in mm (default 5mm)
depth = 5; // .1
// Thickness of the magnet in mm (hole will get a bit of extra clearance)
magnet_thickness = 2; // .1
// Diameter of the magnet in mm (hole will get a bit of extra clearance)
magnet_diameter = 8; // .1
// If the label is less than this wide make only one magnet hole; otherwise make 2 holes
single_magnet_width = 36;



/* [Preview colors settings (preview only, need to paint in slicer)] */
base_color = "black";
text_color = "white";

/* [Printer and offset settings] */
// distance between labels on plate in mm
label_y_offset = 20;
// printer bed size (BambuLab A1/P1/X1 are 255x255, A1 mini is 180x180)
bed_size=[255, 255];
// Layer Height (default .20mm) - must also be configured in slicer!
layer_height=.20; // .01

/* [ Hidden ] */
$fn = 32; // Model detail, higher is more detail and more processing

// I changed this ratio to make the base a little stronger (i had some bend coming off) 
// and to give more room for internal magnets
// Any more than 70/30 and the text really loses the beautiful 3d effect
base_depth=depth*.6; // thickness of base 
text_depth=depth*.4; // thickness of text

// thickness of the bottom layer
// set to 0 automatically if they asked for open holes; otherwise
// as many layers as they asked for
bottom_thickness= hole_type==1 ? bottom_layers*layer_height : 0 ;

// convenience
mag_rad=magnet_diameter/2;

// 2 layers by default, unless they go with a tiny layer height
hole_z_clr_factor=layer_height>=.2 ? layer_height*2 : .4 ;

// controls how much extra space is in the hole for the magnet
// for open holes, use a negative "clearance" so the magnets stick 
// slightly out the bottom
hole_z_clr=hole_type == 0 ? hole_z_clr_factor : -hole_z_clr_factor ;

// clearance added to cylinder's lower radius (r2 of cylinder() )
hole_low_clr=.2;

// clearance added to cylinder's upper radius (r1 of cylinder() )
// taper the cylinder for open holes, same as low clearance for hidden holes
hole_hi_clr= bottom_thickness<=0 ? hole_low_clr/2 :  hole_low_clr ;

// this is the z at which the hole starts - 0 for open hole
mag_hole_z=bottom_thickness;
// this is how deep/thick the hole is; 
mag_hole_depth=magnet_thickness + hole_z_clr;

// split the string of labels into an array 
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


// throw an error if the magnet hole is too deep for the configured base depth; 
// must have at least two layers on top and bottom
assert( ( 2*bottom_thickness + mag_hole_depth ) < base_depth, "magnet hole + bottom thickness too high" );


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

// changed the magnet hole to be uncentered on the Z axis, mades things
// simpler since i was moving the hole around vertically
module magnet_hole() {
    cylinder(mag_hole_depth, mag_rad + hole_low_clr , mag_rad + hole_hi_clr, false);
}

module make_center_hole() {
    translate([0, 0, mag_hole_z])
        magnet_hole();
}

module make_outside_holes(total_width) {
    translate([-total_width/2 + 10, 0, mag_hole_z]) 
        magnet_hole();
    translate([ total_width/2 - 10, 0, mag_hole_z])
        magnet_hole();
}


module make_base(string=$string) {
    tmetrics = textmetrics(string, size = font_size, font = font,
                           halign = "center", valign = "center", $fn=64);
    base_width = tmetrics["size"][0];
    base_height = tmetrics["size"][1];

    // double-check that a single label won't be too wide
    assert(base_width + base_radius < bed_size[0], "label too wide for print bed");
    
    // determines the number & placement of holes
    total_width=base_width+base_radius;
    
    // make the base
    difference() {
        hull() // wrap all words
            minkowski() { // chamfer corners and flow letters
                linear_extrude(base_depth) {
                    if (base_shape)
                        text(string, size=font_size, font=font,
                             halign="center", valign="center", $fn = 64);
                    else
                        square([base_width, base_height], center=true);
                }
                // when the height was 1, the base ended up taller than my base_depth
                cylinder(h=.1, r=base_radius);
            }

        // make one hole if the total size is too small, otherwise make two
        if ( total_width < single_magnet_width ) 
            make_center_hole();
        else 
            make_outside_holes(total_width);

    }
    
}

module make_text(string=$string) {
    translate([0, 0, base_depth])
        linear_extrude(text_depth)
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
