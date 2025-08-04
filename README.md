# usg-label-maker

## Introduction

This is a magnetic label generator that I use to create my labels
for my Harbor Freight US General series tool boxes/tool carts.  You
can easily make a batch of custom labels for tool carts and tool
boxes.

The label generator is written to work either with the Makerworld
Parametric Model Maker (aka the Customize button) or on a local
copy of [OpenSCAD](https://openscad.org/downloads.html#snapshots).

The included .3MF project includes a ton of labels you can use on
their own, but it was my intention that you would use this to make
your own custom labels.

We print these labels with the magnet side down to the bed. The
little amount of bridging needed means that supports should not be
needed.

### Remix Differences

Originally written by Josh who produced a single label. This is
complete rewrite of that code to support batch generation, the
customizer, guardrails, and multi-part and multi-plate printing.
His code was the inspiration for this code.

## Usage

### Option 1: MakerWorld Customizer Button

#### Pros:
- Nothing to install, just customize, download, and print.
- Supports generating up to 4 plates at once.

#### Cons:

You must use one of the fonts supported by the customizer, which
does not include any that match the US General font. Montserrat is
kind of close, but not fantastic.

1. Use the customizer to set the labels you wish to print.
   Labels are delimited with the “|” character.
1. Generate, download
1. Slice and print.




### Option 2: Local OpenSCAD

#### Pros:
- Not limited to Makerworld's font library.

#### Cons:
- More complicated
- Requires OpenSCAD and font installation
- Only supports one plate at a time.
- Base and text are exported as two different parts of the object--just select which color filament to use for each part.

1. Install OpenSCAD development snapshot. The last official release is from 2021 but it is actively maintained and we use features that do not exist in the official release. Hint: if using a recent MacOS, you may need to remove the quarantine flag from the downloaded file before it will run.
1. Download/install desired fonts (see Getting the Fonts below).
1. Go to **OpenSCAD > Preferences > Features** and enable lazy-union and text-metrics.
1. Go to **OpenSCAD > Preferences > Advanced** and set the 3D Rendering backend to **Manifold**.
1. Download the `.SCAD` file, edit it and set the local\_openscad variable to 1 or true.
1. Use the OpenSCAD customizer window or edit the source code to set the labels you wish to print. *Labels are delimited with the “|” character.*
1. If using a different font, set the name of the font in OpenSCAD.
1.  Do a preview rendering (F5), if it looks good, do a slower full rendering (F6), then Export the output as a .3MF file.
1. Load the .3MF file into your slicer, answer Yes when the slicer prompts “Multi-part object detected.”
1. Go to Objects menu, “OpenSCAD Model 1” represents all the bases, “OpenSCAD Model 2” is all of the text parts. Set desired colors or filament for each part.

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

## Interesting Parameters/Variables

See the .scad file for parameters you can change, but briefly:

- *local_openscad*: Running on MakerWorld or locally?
- *labels*: label names, each delimited with "|" like "SOCKETS|RATCHETS|ALLEN WRENCHES”
- *font*: font to use
- *letter_size*: 8mm default
- *label depth*: 5mm default -- includes raised letters
- *base_shape*:
     0: default, a rectangle with rounded corners
     1: Flows base shape to follow letter outlines.
        May produce more aesthetic results but can also look
        strange letters with descenders (angled base) and trailing Ls
        (opposite angle). Slower to render but could be very cool.

It will only generate as many labels in the STL as will fit on the
plate vertically, so you may have to batch your jobs as necessary.
