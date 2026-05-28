# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

OpenSCAD generator for magnetic labels for Harbor Freight US General tool boxes/carts. Single source file `MagneticLabelMaker.scad` runs in two environments — most design decisions follow from supporting both:

- **MakerWorld Customizer**: up to 5 plates per run, color metadata in `.3mf`, restricted to MakerWorld's bundled fonts.
- **Local OpenSCAD** (development snapshot, not the 2021 release): one plate per run, exports base + text as two object parts via `lazy-union` for slicer color assignment, any installed font.

Toggle: `MakerWorld_Customizer_Environment` at the top of the `.scad` file. `font` and the active rendering entry point both branch on it.

## Commands

**OpenSCAD GUI prerequisites:** Preferences > Features must enable `lazy-union` and `text-metrics`; Preferences > Advanced must set 3D backend to **Manifold**.

**Batch CLI** — one STL per badge from a newline-delimited list (blank lines and `#` lines skipped):

```bash
./batchmake.sh badges.txt                # default font
./batchmake.sh -p loadout badges.txt     # smaller magnets + sd prostreet font, outputs into ./loadout/
```

`batchmake.sh` hard-codes the macOS path `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD` and passes `-D` overrides. New parameter presets go in its `case $PARAMETERS` block.

## Architecture

### Rendering pipeline

`iterate_labels(labels)` is the single entry point for both environments:

1. Splits the `|`-delimited string, filters empty entries.
2. Calls `textmetrics()` **once per label** and caches results.
3. Computes a uniform Y-axis slot = `max(label height, magnet_wrap_diameter) + base_radius` over all labels.
4. For each label, translates to a centered Y position and invokes `children()` with `$string` and `$tmetrics` bound as special variables.

`make_base()` and `make_text()` consume `$string` / `$tmetrics` — never re-measure. If you add another per-label module, follow the same pattern. Both modules also accept the values as defaulted args so they remain callable standalone for debugging.

`make_base()` builds the rounded base via `hull() { minkowski() { extrude(square or text); cylinder(r=base_radius); } }`, then subtracts magnet pockets via `place_magnet_holes()`. The minkowski adds `base_radius` on **every** side — the X-axis assertion correctly uses `base_width + 2 * base_radius`.

`place_magnet_holes(base_width)` decides between two end holes (+ optional third center hole on wide labels) vs. a single center hole, based on actual edge-to-edge gap.

### Magnet geometry

`base_depth` is derived from magnet geometry (`magnet_hole_top + 2 * magnet_depth_clearance`). Raised text height = `depth - base_depth` and must be positive — `make_text` asserts this.

`encapsulate_magnets = false` (default): pocket open at the base, magnets drop in. `cut_magnet` is intentionally wider at the bottom so the magnet seats firmly against the cap — don't flip the cone.

`encapsulate_magnets = true`: pocket offset by `magnet_depth_offset` so a thin layer bridges underneath; the print must be paused at the top of the hole to insert magnets.

### Two execution paths

- **MakerWorld:** modules `mw_plate_1()` … `mw_plate_5()` are discovered by naming convention. Each calls `mw_make_labels()` which applies `color()` (translated into `.3mf` metadata).
- **Local:** top-level `if (!MakerWorld_Customizer_Environment)` block renders only `plate_labels_1`, emitting bases and text as separate top-level groups so `lazy-union` keeps them as distinct object parts.

Both paths must funnel through `iterate_labels` → `make_base` / `make_text` so behavior stays in sync.

## Fonts

`font` defaults via ternary on the environment toggle: `Montserrat:style=ExtraBold Italic` on MakerWorld, `sd prostreet` locally. `batchmake.sh` mirrors the same local default. Customizer and `-D font=...` overrides take precedence. Avionic Wide Oblique Black (Fontspring demo) is the closest match to the actual US General typeface and is the documented backup; Concielian Bold Semi Italic also works. Font directories are gitignored.
