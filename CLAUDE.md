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

`iterate_labels(labels)` is the single entry point for both environments. It **2D bin-packs** labels into a centered grid (not a single centered column), routing around configurable exclusion zones:

1. Splits the `|`-delimited string, filters empty entries.
2. Calls `textmetrics()` **once per label** and caches results.
3. Computes each label's **full footprint** — text box grown by `2 * base_radius` per axis (the minkowski adds `base_radius` on every side) — plus a `label_gap` safety margin so neighbouring bases never fuse.
4. Uniform row height (slot) = tallest footprint + `label_gap`.
5. Lays a **centered grid of `floor(bed_y / slot)` row-bands** and carves each band into free X-intervals ("shelves") by subtracting any exclusion zone (inflated by `label_gap`) that intrudes on that band's Y range. A shelf is `[x_min, x_max, y_center]`.
6. Sorts labels widest-first and packs them into shelves via **first-fit-decreasing** (`pack_shelves()` / `fit_shelf()`). Each shelf's run of labels is centered within its free interval.
7. Asserts every label was placed; the message lists the unplaced labels (hard stop — reduce count / font size, shrink zones, or split plates). **Note:** because zones reduce usable area, a label set that fit without zones can now overflow.
8. For each label, translates to its `[x, y]` and invokes `children()` with `$string` and `$tmetrics` bound as special variables.

Exclusion zones are corner-anchored rectangles built by `corner_rect()` from the `exclude_zone_1/2*` parameters into the `exclusion_zones` list (`[x_min, y_min, x_max, y_max]`, bed-centered coords). The packing is done with pure recursive helpers (`corner_rect`, `inflate`, `band_blockers`, `free_intervals`/`sweep`, `sort_by_lo`, `sorted_desc`, `max_index`, `vec_set`, `fit_shelf`, `pack_shelves`) because OpenSCAD has no mutable loop state. Both the bases pass and the text pass call `iterate_labels` with the same labels/params, so the deterministic sort+pack keeps base and text aligned. The grid is anchored (not re-centered on the used rows), so a light label set clusters toward the top bands. Packing assumes label width ≈ text bounding box, so `base_outline=1` still packs by the box, not the glyph silhouette.

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

### Preview-only plate border

`plate_border()` draws a square ring just outside the bed edges (inner edge at `bed_size`, extending `border_thickness` beyond on each side, so it frames the bed without consuming printable area) and `plate_exclusions()` overlays the `exclusion_zones` as translucent red slabs — both visual guides. They're gated by a single `if ($preview)` block at top level: `$preview` is true only for on-screen preview (F5/GUI) and false during full render and every export (F6, CLI `-o`, MakerWorld), so neither **ever** enters an STL/3MF. Use the same `$preview` guard for any future reference-only geometry — don't rely on the `%` modifier, which lazy-union can still surface as a stray object part.

## Fonts

`font` defaults via ternary on the environment toggle: `Montserrat:style=ExtraBold Italic` on MakerWorld, `sd prostreet` locally. `batchmake.sh` mirrors the same local default. Customizer and `-D font=...` overrides take precedence. Avionic Wide Oblique Black (Fontspring demo) is the closest match to the actual US General typeface and is the documented backup; Concielian Bold Semi Italic also works. Font directories are gitignored.
