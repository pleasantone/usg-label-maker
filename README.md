# usg-label-maker
Toolbox magnetic label generator in a font nearluy matching Harbor Freight's US General font.

The label generator is written in [OpenSCAD](https://openscad.org) and is a remix from [Magnetic Label Maker](https://www.printables.com/model/167349-magnetic-label-maker-scad).

The font that I use came from Fontspring and is their [Avionic Wide Oblique Black](https://www.fontspring.com/fonts/grype-type/avionic).
In the sample code, I have referred to their Demo license copy so you can easily test,
obviously you should either change fonts or buy a personal license should you use this for a finished project or commercially.

The improvement to this label maker (from the original) are:
  * can produce several labels at once
  * auto-sizes the bounding box for the labels
  * paints the text (during preview) so it's easier to read
  * checks to see if the label will exceed the bed-size of your printer
    
See the .scad file for parameters you can change, but briefly:
  *font*:  font to use
  *letter_size*: 8mm default
  *label depth*: 5mm default
  *labels*: array of names like ["SOCKETS", "RATCHETS"]

It will only generate as many labels in the STL as will fit on the plate vertically, so you may have to batch your jobs (hence the labels1, labels2, ...).


Painting/Multi-Color:
If using an AMS, have your slicer cut the object on the Z plane, keeping both object together, and specify a different filament color (I use white on black) for the lettering over the background box. If you don't have an AMS, obviously do a filament change mid-print.
