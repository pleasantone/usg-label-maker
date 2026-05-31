# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased] — 2026-05-31

### Fixed

- **X-axis bed assertion underestimated label width.** `make_base` checked `base_width + base_radius < bed_size.x`, but `minkowski` with the corner cylinder adds `base_radius` on **both** sides. Labels could overhang the X edge by up to one `base_radius`. Now uses `base_width + 2 * base_radius`.
- **First label was half off the back of the bed.** `iterate_labels` placed the first label's center at `y = -bed_size.y / 2`, but labels render with `valign = "center"`. Labels are now centered inside their Y slot (`-bed_size.y / 2 + slot * (index + 0.5)`).
- **Top-edge Y assertion was overly conservative.** The previous `y_start < bed_size.y / 2 - offset * 2` rejected labels that actually fit. Tightened to `y_center + slot / 2 <= bed_size.y / 2`, recovering roughly 1.5 slots of usable Y per plate.
- **Magnet-gap calculation overcounted by one full diameter.** `make_base` computed `magnet_separation = base_width - 2 * (magnet_edge_inboard + magnet_diameter + magnet_bottomcyl_clearance)`, treating the diameter as a per-side radius. The actual edge-to-edge gap is `magnet_diameter` larger, so wide labels were falling back to a single center hole when two end holes (and sometimes a third center hole) actually fit. Now correctly uses `magnet_diameter / 2` per side.
- **`make_text` silently produced no text when `depth ≤ base_depth`.** Setting `depth` below the magnet-driven minimum gave `linear_extrude` a non-positive height. Added a clear assertion with both values and an actionable hint.
- **Delimiter-only label strings rendered ghost labels.** `mw_make_labels`'s `if (len(labels))` guard let strings like `"|"` through, which then split into `["", ""]` and produced empty stubs. `iterate_labels` now filters empty entries after splitting and skips the render entirely if nothing remains.
- **`batchmake.sh` `loadout` preset overrides were silently no-ops.** The preset passed `-D magnet_cylinder_top_clearance=...` and `-D magnet_cylinder_bottom_clearance=...` but the actual variables are `magnet_topcyl_clearance` and `magnet_bottomcyl_clearance`. Fixed the names so the preset now applies the intended smaller magnet clearances.
- **`batchmake.sh` mangled labels containing `"`.** Bash's `-D plate_labels_1="\"$item\""` left embedded double-quotes unescaped, producing an unterminated OpenSCAD string (which is why `badges.txt` had `#1/2\" RATCHETS` lines commented out). Backslashes and quotes are now escaped before substitution; labels like `1/2" RATCHETS` render correctly.
- **`batchmake.sh` dropped the last badge when the input file had no trailing newline.** Classic `while read` gotcha; now uses `|| [[ -n "$item" ]]` to keep the final line.
- **`batchmake.sh` silently ignored extra positional arguments.** `./batchmake.sh badges.txt extra` accepted and ignored `extra`; it now errors.
- **`batchmake.sh` failed inside the rendering loop when the OpenSCAD binary or source file was missing.** Pre-flight checks now verify the OpenSCAD binary, source `.scad` file, input file, and output directory writability before the first render.
- **`batchmake.sh` only worked from the repo root.** `MagneticLabelMaker.scad` was referenced as a relative path; the script now resolves it relative to its own location, so it works from any CWD or via cron.
- **`batchmake.sh` error in the parameter-set case referenced the wrong variable.** `echo "Error: unknown parameter set $1"` printed whatever `$1` happened to be after argument parsing (usually the input filename). Now prints the actual `$PARAMETERS` value.
- **`batchmake.sh` `sanitize_filename` could produce empty filenames** for all-symbol labels (e.g. `///` → `part_.stl`), colliding across badges. Now falls back to `unnamed`, collapses runs of hyphens, and maps `/` to `-` instead of stripping it.
- **README parameter names matched an earlier draft of the code.** Updated to `font_size`, `depth`, `base_outline`, `plate_labels_1`..`5`, and `MakerWorld_Customizer_Environment`.

### Changed

- **Default font now follows the environment.** `font` evaluates to `"Montserrat:style=ExtraBold Italic"` when running under MakerWorld and `"sd prostreet"` locally, instead of requiring a manual swap of commented lines. `batchmake.sh` mirrors the same local default. Avionic Wide Oblique Black (Fontspring demo) is now documented as the backup option for the closest US General match. Customizer and `-D font=...` overrides still take precedence.
- **`textmetrics` is computed once per label.** `iterate_labels` precomputes metrics for all labels up front and propagates them via the special variable `$tmetrics`. `make_base` consumes that instead of re-measuring, eliminating roughly 3× redundant calls per plate.
- **Magnet hole placement extracted to `place_magnet_holes(base_width)`.** The two-vs-one-vs-three hole decision is now a standalone module with clearer naming (`magnet_outer_radius`, `magnet_gap`) instead of being nested inside `make_base`'s `difference()`.
- **Labels now bin-pack into a centered grid instead of a single centered column.** `iterate_labels` measures each label's full footprint (text box + `2 * base_radius` per axis), sorts widest-first, and packs them into rows via first-fit-decreasing (`sorted_desc` / `first_fit` / `pack` helpers), filling the bed on both axes. Each row is centered horizontally and the whole block is centered on the bed origin, dramatically increasing labels per plate. The Y-space assertion now reports the required row count.
- **`label_y_extra_spacing` replaced by `label_gap`.** A single safety-gap parameter (default `1`mm) applied on **both** axes so neighbouring footprints never fuse during packing.
- **Local path renders all five plate lists concatenated.** `plate_labels` joins `plate_labels_1`..`5` with `|`, so a local run packs every label onto one plate (subject to the bed-space assertion) rather than only `plate_labels_1`.
- **Removed dead `$fn = 64` overrides on `textmetrics()` calls.** `textmetrics` returns size data and doesn't use `$fn`. Applied `$fn = 64` to `cut_magnet` instead, where it actually produces rounder magnet holes.

### Added

- Comments documenting non-obvious patterns: the `$string` / `$tmetrics` special-variable binding in `iterate_labels`, the intentionally asymmetric cone in `cut_magnet` (wider at the bottom so magnets seat against the cap), and the minkowski-adds-on-both-sides reasoning behind the X assertion.
- **`batchmake.sh` hardening.** `set -euo pipefail`, errors emitted to stderr, `[N/total]` progress indicator, `-h`/`--help` flag, `OPENSCAD` env var override for the binary path, and comments marking the intentionally-unquoted `$EXTRA` word-splitting.
- `CLAUDE.md` with architecture notes and build/batch commands for future Claude Code sessions.
- **Preview-only plate-edge border.** `plate_border()` draws a square frame at the bed edges (`border_thickness`, default `3`mm) so the printable area is visible while arranging labels. Gated by `if ($preview)`, so it appears in on-screen preview but is excluded from every render/export (STL/3MF).
