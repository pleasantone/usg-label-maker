#!/bin/bash

#badges="METRIC SOCKETS|SAE SOCKETS|SPECIALTY SOCKETS|CHISELS|PUNCHES|BRAKE TOOLS|HAMMERS|TORQUE WRENCHES|PRY BARS|SCREWDRIVERS|SAE WRENCHES|METRIC WRENCHES|VISE GRIPS|PILERS|AIR TOOLS|POWER TOOLS|JUNK|SNACKS|ELECTRICAL TOOLS|ELECTRICAL DIAGNOSTICS|PICKS|RATCHETS|SHEARS|ALLEN|TORX|MISC|HARDWARE|EXTENSIONS|BREAKER BARS|HEX KEYS|SAE|METRIC|SOCKETS|PLIERS|ELECTRICAL|NO TOUCH|BITS|IMPACT WRENCHES|1/4\\\" RATCHETS|3/8\\\" RATCHETS|1/2\\\" RATCHETS|I WASN'T ASKING TOOL"


badges="SAE SOCKETS|METRIC SOCKETS|RATCHETS|SCREWDRIVERS|WRENCHES|TORQUE WRENCHES|PLIERS|BIT SETS|POWER TOOLS|ELECTRICAL|CHISELS|PICKS|TORX|ALLEN|JUNK|RIVETING|SHEARS|MEASURING|MISC|PPE|MOTORCYCLE|MARKING|MAGNETS|PRY BARS|BRUSHES|CRIMPERS|SOLDERING|HAMMERS|LIGHTS|ZIP TIES|TAPE|DRILL BITS|ADHESIVES|SEALANTS|AUTOMOTIVE TOOLS|OILS|PAINT|SPECIALTY SOCKETS|BRAKE TOOLS|HAMMERS|SAE WRENCHES|METRIC WRENCHES|VISE GRIPS|AIR TOOLS|POWER TOOLS|SNACKS|ELECTRICAL TOOLS|ELECTRICAL DIAGNOSTICS|ALLEN|TORX|HARDWARE|EXTENSIONS|BREAKER BARS|HEX KEYS|SAE|METRIC|SOCKETS|ELECTRICAL|NO TOUCH|BITS|IMPACT WRENCHES|1/4\\\" RATCHETS|3/8\\\" RATCHETS|1/2\\\" RATCHETS|I WASN'T ASKING TOOL|1/4 RATCHETS|3/8 RATCHETS|1/2 RATCHETS";

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

# Save the original IFS value to restore it later
OLD_IFS=$IFS

# Set IFS to a comma to split the string by commas
IFS='|'

# Iterate over the items in the string
for item in $badges; do
  file=$(sanitize_filename "$item")
  echo "Processing item: $item to $file"
  # Build the OpenSCAD command
  # -D defines a variable in the script
  # -o specifies the output file name
  set -x
  /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
      --enable textmetrics --enable lazy-union \
      -D font="\"sd prostreet\"" -D openscad_mode=1 \
      -D magnet_depth=2 -D plate_labels_1="\"$item\"" \
      -o part_$file.stl MagneticLabelMaker.scad
  set +x
done

# Restore the original IFS value
IFS=$OLD_IFS
