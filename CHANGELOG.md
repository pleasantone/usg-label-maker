# Changelog

All notable changes to this project are documented in this file. From v1.0.0
onward it is maintained automatically by
[release-please](https://github.com/googleapis/release-please) from
[Conventional Commits](https://www.conventionalcommits.org/); newer releases are
prepended above the 1.0.0 entry.

## [1.0.0](https://github.com/pleasantone/usg-label-maker/releases/tag/v1.0.0) (2026-05-31)

Complete rewrite of the original single-label remix into a batch/customizer
generator. Summary of the current behavior:

### Added

- **2D bin-packing layout.** `iterate_labels` measures each label once, grows its
  text box by `2 * base_radius` per axis (floored at `magnet_wrap_diameter` so
  the base never shrinks below its magnet pocket), then lays a centered grid of
  uniform-height row-bands and packs labels widest-first (first-fit decreasing)
  into the free X-intervals of each band. Fills the bed on both axes; the
  placement assertion names any labels that couldn't be placed.
- **Configurable exclusion zones.** Two corner-anchored keep-out rectangles
  (`exclude_zone_1/2`, each with `_corner` and `_size`) that the packer routes
  around — defaults reserve the Bambu X1C front-left cutter/wipe area
  (18×28mm) and a prime-tower space (55×55mm). Zones reduce usable area, so a
  set that fit without them may overflow.
- **Preview-only reference geometry.** `plate_border()` frames the bed just
  outside its edges (`border_thickness`, default 3mm) and `plate_exclusions()`
  overlays the keep-out zones in translucent red. Both are gated by `$preview`,
  so they appear in on-screen preview (F5) but never enter any STL/3MF export.
- **Hardened `batchmake.sh`.** One STL per badge from a newline-delimited list
  (blank/`#` lines skipped), `set -euo pipefail`, pre-flight checks (binary,
  source, input, output dir), `[N/total]` progress, `-h`/`--help`, `OPENSCAD`
  env override, a `loadout` preset (smaller magnets → `./loadout/`), label
  escaping for `"`/`\`, and filename sanitization with an `unnamed` fallback.
- `CLAUDE.md` with architecture notes and build/batch commands.

### Changed

- **Default font follows the environment** — `"Montserrat:style=ExtraBold
  Italic"` on MakerWorld, `"sd prostreet"` locally (mirrored by `batchmake.sh`);
  Avionic Wide Oblique Black documented as the closest-USG-match backup.
  Customizer and `-D font=...` overrides still take precedence.
- **`textmetrics` computed once per label** and propagated via `$tmetrics`, so
  `make_base`/`make_text` never re-measure.
- **Magnet placement extracted to `place_magnet_holes()`** — the
  two-vs-one-vs-three-hole decision, with edge-to-edge gap math that correctly
  treats `magnet_diameter / 2` as the per-side radius.
- **Single `label_gap` safety margin** (default 1mm, both axes) replaces the
  old `label_y_extra_spacing`.

### Fixed

- **Bed-fit math.** The X assertion now accounts for `minkowski` adding
  `base_radius` on **both** sides (`base_width + 2 * base_radius`), and base
  width/height are both floored at `magnet_wrap_diameter` so a short label
  (e.g. `"A"`) can't let its magnet pocket break through the wall.
- **`make_text` asserts `depth > base_depth`** instead of silently emitting no
  text when `depth` falls below the magnet-driven minimum.
- **Delimiter-only strings** like `"|"` no longer render ghost labels —
  `iterate_labels` filters empty entries and skips an otherwise-empty render.
- **`batchmake.sh` robustness:** parses correctly (the `avionic` case had a
  missing `;;`), no longer trips `set -u` on `OUTDIR`, keeps the last badge when
  the file lacks a trailing newline, errors on unknown options / extra
  arguments / unknown presets, resolves the `.scad` path relative to itself
  (works from any CWD), and applies the `loadout` preset's real variable names.
- **README** parameter names and instructions match the current code (`font_size`,
  `depth`, `base_outline`, `plate_labels_1`..`5`,
  `MakerWorld_Customizer_Environment`, 5 plates, both-axes packing).
