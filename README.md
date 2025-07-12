# usg-label-maker

Toolbox magnetic label generator.

You can use any font, but this is designed around a font nearly matching Harbor
Freight's US General font.

The label generator is written in [OpenSCAD](https://openscad.org)
and is a remix from [Magnetic Label
Maker](https://www.printables.com/model/167349-magnetic-label-maker-scad).

## Getting the fonts

You can use any TTF font you want. You can either copy the font
file into the same directory as the .scad file, or install it in
your system fonts.

The font that I use came from Fontspring and is their [Avionic Wide
Oblique Black](https://www.fontspring.com/fonts/grype-type/avionic).

In the sample code, I have referred to their Demo license copy so
you can easily test, obviously you should either change fonts or
buy a personal license should you use this for a finished project
or commercially.  Note that the individual Wide Oblique Black 
weight can be purchased separately.  You do not have to purchase the 
entire font family.


## Remix Improvements

The improvement to this label maker (from the original) are:

* can produce several labels at once
* auto-sizes the bounding box for the labels
* paints the text (during preview) so it's easier to read
* checks to see if the label will exceed the bed-size of your printer
* allows choice between internal magnets and holes in the bottom

## Interesting Parameters/Variables

See the .scad file for parameters you can change, but briefly:
  *labels*: array of names like ["SOCKETS", "RATCHETS"]
  *font*:  font to use
  *hole type*: specify open holes on the bottom or internal holes
  *letter_size*: 8mm default
  *label depth*: 5mm default -- includes raised letters
  *layer height*: default .20mm.  handles some calculations internally 
    based on layer height.  
  *base_follows_letter*: false default -- experimental
    flowing of base to follow letter outlines.
    May produce more aesthetic results but can also look
    strange with letters with descenders like Q (angled base) and trailing Ls
    (opposite angle). Also slow to render.

It will only generate as many labels as will fit on the plate
vertically, so you may have to batch your jobs (hence the labels1,
labels2, ...).

## Painting/Multi-Colors

If using an AMS, have your slicer cut the object on the Z plane,
keeping both object together, and specify a different filament color
(I use white on black) for the lettering over the background box.
If you don't have an AMS, obviously do a filament change mid-print.

## Hidden holes

You can include the magnets internally in your labels, instead
of gluing them in place or hoping for the best with a friction fit.

When you slice the project, tell the slicer to pause after it prints 
the highest level of the hole.  You'll have to look at the layers
to figure out what layer this is.  

In Bambu Studio, you do this by adjusting the green bar to the right
of the Preview window.  Once you've found the right height, right-click
on the adjustment on the bar and tell it to add a pause.

## Documentation from the original project by @Josh:

These are labels with recesses underneath them for magnets. The
.stl files uploaded are the ones I used. They use 8mm x 3mm magnets
*(correction: my version uses 8x2)* and are 17.4mm tall.

I also uploaded the .scad file to allow you to make whatever label
you want and to modify the magnet size. If you choose to make your
own labels, OpenSCAD is how I created them - it's a free program
and would allow you to modify my .scad file to your needs. When you
modify it, I set up a couple of variables to allow changing the
font, resizing the text, resizing the box, and changing the magnet
dimensions easy.

Why I used SCAD:

I wanted to make magnetic labels for my workbenches and, with the
number I'd need to make, thought this would be a good time to learn
how to use .scad rather than making each label manually. A couple
hours learning to use scad and putting this together allowed me to
generate STLs for all of these labels in under 10 minutes.
