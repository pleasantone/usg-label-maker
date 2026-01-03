#!/bin/bash

PARAMETERS=""
INPUT=""
EXTRA=""
FONT='FONTSPRING DEMO \\- Avionic Wide Oblique Black'

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--parameters)
            PARAMETERS="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option $1"
            exit 1
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            fi
            shift
            ;;
    esac
done

# Check if mandatory positional argument was provided
if [[ -z "$INPUT" ]]; then
    echo "Error: Missing input file"
    echo "Usage: $0 [-p|--parameters MODE] <filename>"
    exit 1
fi

case $PARAMETERS in
    loadout)
        EXTRA="-D magnet_diameter=6 -D magnet_cylinder_top_clearance=0.0 -D magnet_cylinder_bottom_clearance=0.1 -D magnet_center_hole_width=100"
        FONT="sd prostreet"
        ;;
    "")
        ;;
    *)
        echo "Error: unknown parameter set $1"
        exit 1
        ;;
esac

if [ ! -r "$INPUT" ]; then
  echo "Error: File '$INPUT' is not readable."
  exit 1
fi

sanitize_filename() {
  local input="$1"
  local cleaned_name

  # Replace spaces and other common separators with hyphens
  cleaned_name=$(echo "$input" | tr ' ' '-' | tr '_."' '-')

  # Remove any characters that are not alphanumeric or hyphens
  cleaned_name=$(echo "$cleaned_name" | sed 's/[^a-zA-Z0-9-]//g')

  # Convert to lowercase (optional, but good for consistency)
  cleaned_name=$(echo "$cleaned_name" | tr '[:upper:]' '[:lower:]')

  # Remove duplicate hyphens
  #cleaned_name=$(echo "$cleaned_name" | sed 's/-\{2,\}/-/g')

  # Remove leading/trailing hyphens
  cleaned_name=$(echo "$cleaned_name" | sed 's/^-//;s/-$//')

  echo "$cleaned_name"
}

if [[ -n "$PARAMETERS" ]]; then
  test -d $PARAMETERS || mkdir $PARAMETERS
else
  PARAMETERS=.
fi

while IFS= read -r item ; do
  # ignore empty or lines starting with #
  case "$item" in
    ''|\#*) continue ;;
  esac

  file=part_$(sanitize_filename "$item").stl
  echo "Processing badge: $item to $file"
  # Build the OpenSCAD command
  # -D defines a variable in the script
  # -o specifies the output file name
  /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
      --enable textmetrics --enable lazy-union \
      -D MakerWorld_Customizer_Environment=false \
      -D plate_labels_1="\"$item\"" \
      -D font="\"$FONT\"" \
      $EXTRA \
      -o $PARAMETERS/$file MagneticLabelMaker.scad || { echo "failed"; exit 1; }
done < $INPUT
