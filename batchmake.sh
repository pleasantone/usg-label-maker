#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SCAD_FILE="${SCRIPT_DIR}/MagneticLabelMaker.scad"
OPENSCAD="${OPENSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"

# Default local font; Avionic Wide Oblique Black is the closest USG match and
# can be substituted here as a backup: 'FONTSPRING DEMO \\- Avionic Wide Oblique Black'
FONT='sd prostreet'
AVIONIC_FONT='FONTSPRING DEMO \\- Avionic Wide Oblique Black'
PARAMETERS=""
INPUT=""
EXTRA=""
OUTDIR=""

die() { echo "Error: $*" >&2; exit 1; }

usage() {
    cat >&2 <<EOF
Usage: $0 [-p|--parameters MODE] <filename>
  MODE: loadout (smaller magnets, outputs to ./loadout/)
  Input <filename> contains one badge per line. Blank lines and '#' comments are skipped.
  Override OpenSCAD path with the OPENSCAD environment variable.
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--parameters)
            [[ $# -ge 2 ]] || die "Missing value for $1"
            PARAMETERS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            die "Unknown option $1"
            ;;
        *)
            [[ -z "$INPUT" ]] || die "Unexpected extra argument: $1"
            INPUT="$1"
            shift
            ;;
    esac
done

[[ -n "$INPUT" ]] || usage

case "$PARAMETERS" in
    loadout)
        EXTRA="-D magnet_diameter=6 -D magnet_topcyl_clearance=0.0 -D magnet_bottomcyl_clearance=0.1 -D magnet_center_hole_width=100"
        OUTDIR="loadout"
        ;;
    avionic)
        FONT="$AVIONIC_FONT"
        ;;
    "")
        ;;
    *)
        die "Unknown parameter set '$PARAMETERS'"
        ;;
esac

# Pre-flight: fail fast with a clear message before touching the loop.
[[ -x "$OPENSCAD" ]]  || die "OpenSCAD binary not found or not executable: $OPENSCAD (override with OPENSCAD env var)"
[[ -r "$SCAD_FILE" ]] || die "Source file not found: $SCAD_FILE"
[[ -r "$INPUT" ]]     || die "Input file '$INPUT' is not readable"

if [[ -n "$OUTDIR" ]]; then
    mkdir -p "$OUTDIR"
else
    OUTDIR="."
fi
[[ -w "$OUTDIR" ]] || die "Output directory '$OUTDIR' is not writable"

sanitize_filename() {
    local name="$1"
    # spaces, underscores, dots, quotes, slashes → hyphens; lowercase
    name=$(printf '%s' "$name" | tr ' _."/' '-----' | tr '[:upper:]' '[:lower:]')
    # strip remaining non-alphanumeric/hyphen, collapse and trim hyphens
    name=$(printf '%s' "$name" | sed 's/[^a-z0-9-]//g' | tr -s '-' | sed 's/^-//; s/-$//')
    # all-symbol inputs sanitize to empty; fall back so we don't produce part_.stl
    [[ -n "$name" ]] || name="unnamed"
    printf '%s' "$name"
}

# Count badges (non-empty, non-comment lines) for the progress indicator.
# `|| true` keeps `set -e` happy when grep finds zero matches.
total=$(grep -cEv '^(#|[[:space:]]*$)' "$INPUT" || true)
count=0

# `|| [[ -n "$item" ]]` keeps the last line when the file has no trailing newline.
while IFS= read -r item || [[ -n "$item" ]]; do
    case "$item" in
        ''|\#*) continue ;;
    esac

    count=$((count + 1))
    file="part_$(sanitize_filename "$item").stl"
    echo "[$count/$total] Processing badge: $item -> $OUTDIR/$file"

    # Escape backslashes then quotes so labels containing " or \ survive the
    # bash → OpenSCAD argv handoff. Without this, e.g. `1/2" RATCHETS` produces
    # an unterminated OpenSCAD string.
    escaped=${item//\\/\\\\}
    escaped=${escaped//\"/\\\"}

    # $EXTRA is intentionally unquoted: it holds multiple -D flags that must
    # word-split into separate argv entries.
    "$OPENSCAD" \
        --enable textmetrics --enable lazy-union \
        -D MakerWorld_Customizer_Environment=false \
        -D plate_labels_1="\"$escaped\"" \
        -D font="\"$FONT\"" \
        $EXTRA \
        -o "$OUTDIR/$file" "$SCAD_FILE" || die "OpenSCAD failed on badge: $item"
done < "$INPUT"
