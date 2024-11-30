# usg-label-maker

Toolbox magnetic label generator in a font nearly matching Harbor
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
or commercially.

## Remix Improvements

The improvement to this label maker (from the original) are:

* can produce several labels at once
* auto-sizes the bounding box for the labels
* paints the text (during preview) so it's easier to read
* checks to see if the label will exceed the bed-size of your printer

## Interesting Parameters/Variables

See the .scad file for parameters you can change, but briefly:
  *labels*: array of names like ["SOCKETS", "RATCHETS"]
  *font*:  font to use
  *letter_size*: 8mm default
  *label depth*: 5mm default -- includes raised letters
  *base_follows_letter*: false default -- experimental
    flowing of base to follow letter outlines.
    May produce more aesthetic results but can also look
    strange letters with descenders (angled base) and trailing Ls
    (opposite angle). Also very slow to render.

It will only generate as many labels in the STL as will fit on the
plate vertically, so you may have to batch your jobs (hence the
labels1, labels2, ...).

## Painting/Multi-Colors

If using an AMS, have your slicer cut the object on the Z plane,
keeping both object together, and specify a different filament color
(I use white on black) for the lettering over the background box.
If you don't have an AMS, obviously do a filament change mid-print.

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
