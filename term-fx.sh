#! /bin/bash

##########################################################################################
# Title: Terminal Effects Utility Script
# Author: Kyle Bader
# Date: 2024
# Description:
#   This script provides various functions for manipulating terminal output colors and
#   effects. It includes utilities to convert RGB values to ANSI color codes and
#   to apply text formatting options like bold, underline, and blink. It's designed
#   to enhance terminal interface by providing visually distinct output based on 
#   specified RGB color inputs.
#
# Usage:
#   Source this script in other bash scripts or use functions directly from the command
#   line to transform terminal text styling dynamically. It supports both 8-bit and
#   24-bit color terminals, with fallback to  the closest 8-bit as well as nearest
#   ANSI terminal colors.
#
# Public Functions:
#   - term_fx::set_fx: Apply text formatting with extensive options.
#   - term_fx::clear_fx: Reset text formatting to default terminal settings.
#   - term_fx::hsv_to_rgb: Converts HSV to RGB format.
#
# Internal Functions
#   - _rgb_to_ansi_bg: Converts RGB to closest ANSI background color code.
#   - _rgb_to_ansi_fg: Converts RGB to closest ANSI foreground color code.
#   - _rgb_to_8bit: Converts 24-bit RGB color to an 8-bit terminal color index.
#
# Example:
#   source term_fx.sh
#   red=$(term_fx::hsv_to_rgb 0)
#   yellow=$(term_fx::hsv_to_rgb 60)
#   green=$(term_fx::hsv_to_rgb 120)
#
#   term_fx::set_fx $red
#   echo "This is colored red"
#   term_fx::clear_fx
#   echo "This is the default style"
##########################################################################################


##########################################################################################
# Function: _rgb_to_ansi_bg
#
# Purpose:
#   Converts a single RGB color value provided as a string "R,G,B" into the closest
#   specified ANSI background color code. This function calculates the Euclidean
#   distance between the provided RGB value and a predefined set of ANSI color RGB values
#   to determine the closest match.
#
# Usage:
#   _rgb_to_ansi_bg "R,G,B"
#
#   Where "R,G,B" is a single string with each component separated by commas,
#   and each component (R, G, B) should be in the range of 0 to 255.
#
# Parameters:
#   $1 - A single string containing the red, green, and blue components of the color,
#        formatted as "R,G,B".
#
# Stdout:
#   Prints the ANSI background color code that is closest to the provided RGB values.
#
# Stderr
#   If the RGB string is not provided correctly, the function will print an error message
#   to stderr.
#
# Returns:
#   0 Success
#   1 Invalid rgb parameter
#
# Example:
#   closest_code=$(_rgb_to_ansi_bg "135,206,235")
#   echo "Closest ANSI background color code is: $closest_code"
##########################################################################################
_rgb_to_ansi_bg() {
    local rgb="$1"
    local r g b

    # Parse the RGB values from the input string
    IFS=',' read -r r g b <<< "$rgb"

    # Validate rgb
    if [[ -z "$rgb" || -z "$r" || -z "$g" || -z "$b" ]]; then
      echo "Error: No RGB color provided." >&2
      return 1
    fi

    # Define the ANSI colors and their RGB components
    declare -A colors
    colors[40]="0,0,0"        # Black
    colors[41]="205,0,0"      # Red
    colors[42]="0,205,0"      # Green
    colors[43]="205,205,0"    # Yellow
    colors[44]="0,0,238"      # Blue
    colors[45]="205,0,205"    # Magenta
    colors[46]="0,205,205"    # Cyan
    colors[47]="230,230,230"  # White

    # Initialize minimum distance and closest color code variables
    local min_distance=999999
    local closest_color_code=""

    # Iterate through the colors to find the closest match
    for code in "${!colors[@]}"; do
        # Extract RGB components from the color definition
        IFS=',' read -r color_r color_g color_b <<< "${colors[$code]}"

        # Calculate the Euclidean distance to the input color
        local distance=$(echo "sqrt(($r - $color_r)^2 + ($g - $color_g)^2 + ($b - $color_b)^2)" | bc -l)

        # Update the closest color if the current distance is smaller
        if (( $(echo "$distance < $min_distance" | bc -l) )); then
            min_distance=$distance
            closest_color_code=$code
        fi
    done

    # Output the closest ANSI foreground color code
    echo $closest_color_code
}

##########################################################################################
# Function: _rgb_to_ansi_fg
#
# Purpose:
#   Converts a single RGB color value provided as a string "R,G,B" into the closest
#   specified ANSI foreground color code. This function calculates the Euclidean
#   distance between the provided RGB value and a predefined set of ANSI color RGB values
#   to determine the closest match.
#
# Usage:
#   _rgb_to_ansi_fg "R,G,B"
#
#   Where "R,G,B" is a single string with each component separated by commas,
#   and each component (R, G, B) should be in the range of 0 to 255.
#
# Parameters:
#   $1 - A single string containing the red, green, and blue components of the color,
#        formatted as "R,G,B".
#
# Stdout:
#   Prints the ANSI foreground color code that is closest to the provided RGB values.
#
# Stderr
#   If the RGB string is not provided correctly, the function will print an error message
#   to stderr.
# Returns:
#   0 Success
#   1 Invalid rgb parameter
#
# Example:
#   closest_code=$(_rgb_to_ansi_fg "135,206,235")
#   echo "Closest ANSI foreground color code is: $closest_code"
#
##########################################################################################
_rgb_to_ansi_fg() {
    local rgb="$1"
    local r g b

    # Parse the RGB values from the input string
    IFS=',' read -r r g b <<< "$rgb"

    # Validate rgb
    if [[ -z "$rgb" || -z "$r" || -z "$g" || -z "$b" ]]; then
      echo "Error: No RGB color provided." >&2
      return 1
    fi

    # Define the ANSI colors and their RGB components
    declare -A colors
    colors[30]="0,0,0"        # Black
    colors[31]="205,0,0"      # Red
    colors[32]="0,205,0"      # Green
    colors[33]="205,205,0"    # Yellow
    colors[34]="0,0,238"      # Blue
    colors[35]="205,0,205"    # Magenta
    colors[36]="0,205,205"    # Cyan
    colors[37]="230,230,230"  # White

    # Initialize minimum distance and closest color code variables
    local min_distance=999999
    local closest_color_code=""

    # Iterate through the colors to find the closest match
    for code in "${!colors[@]}"; do
        # Extract RGB components from the color definition
        IFS=',' read -r color_r color_g color_b <<< "${colors[$code]}"

        # Calculate the Euclidean distance to the input color
        local distance=$(echo "sqrt(($r - $color_r)^2 + ($g - $color_g)^2 + ($b - $color_b)^2)" | bc -l)

        # Update the closest color if the current distance is smaller
        if (( $(echo "$distance < $min_distance" | bc -l) )); then
            min_distance=$distance
            closest_color_code=$code
        fi
    done

    # Output the closest ANSI foreground color code
    echo $closest_color_code
}

##########################################################################################
# Function: _rgb_to_8bit
#
# Purpose:
#   Converts a single 24-bit RGB color value (provided as a single string "R,G,B")
#   into an 8-bit color index suitable for use in terminals that support 256 colors.
#   This function maps RGB values onto the 6x6x6 color cube which is part of the 
#   256-color palette used in many terminal emulators.
#
# Usage:
#   _rgb_to_8bit "R,G,B"
#
#   Where "R,G,B" is a single string with each component separated by commas,
#   and each component (R, G, B) ranges from 0 to 255.
#
# Parameters:
#   $1 - A single string containing the red, green, and blue components of the color,
#        formatted as "R,G,B".
#
# Stdout:
#   Prints the 8-bit color index which can be used in terminal escape sequences to set
#   text or background colors. The function prints this value to stdout and can be
#   captured into a variable if used in a script.
#
# Stderr
#   If the RGB string is not provided correctly, the function will print an error message
#   to stderr and return a status of 1.
#
# Returns:
#   0 Success
#   1 Invalid rgb parameter
#
# Example:
#   # Convert RGB color "135,206,235" to an 8-bit terminal color index
#   color_index=$(_rgb_to_8bit "135,206,235")
#   echo "The 8-bit color index is: $color_index"
#
##########################################################################################
_rgb_to_8bit() {
    local rgb=$1
    local r g b

    # Parse the RGB values from the input string
    IFS=',' read -r r g b <<< "$rgb"

    # Validate rgb
    if [[ -z "$rgb" || -z "$r" || -z "$g" || -z "$b" ]]; then
      echo "Error: No RGB color provided." >&2
      return 1
    fi

    # Scale RGB from 0-255 to 0-5
    local red=$(($r * 5 / 255))
    local green=$(($g * 5 / 255))
    local blue=$(($b * 5 / 255))

    # Calculate the 8-bit color value:
    local val=$((16 + (36 * red) + (6 * green) + blue))

    # Print the 8-bit color value
    echo $val
}

##########################################################################################
# Function: term_fx::clear_fx
#
# Purpose:
#   Resets all terminal formatting to the default settings. This function outputs the ANSI
#   escape sequence that clears all custom text styles such as color, boldness, or underline
#   that may have been set previously in the terminal session.
#
# Usage:
#   term_fx::clear_fx
#
#   This function can be called directly in a script or from the command line to reset the
#   terminal's display attributes to their defaults.
#
# Returns:
#   0 Always
#
# Example:
#   term_fx::set_fx "255,255,0"
#   echo -e "This is in custom style."
#   term_fx::clear_fx
#   echo -e "This is in the default terminal style."
#
# Notes:
#   This function is particularly useful in scripts where the text format needs to be changed
#   temporarily and then reset, ensuring that the terminal does not continue to display text
#   in the last set format after the script's execution.
##########################################################################################
term_fx::clear_fx() {
  echo '\e[0m'
}

##########################################################################################
# Function: term_fx::set_fx
#
# Purpose:
#   Generates and outputs an ANSI escape sequence for extensive terminal styling options.
#   This function allows for setting the foreground and background colors with 24-bit RGB
#   values, with automatic fallback to closest colors in the 8 bit range first, 
#   and finally to the closest default terminal color.
#   It enables various text formatting options like bold, italic, underline,
#   strikethrough, blinking, and overlined.
#   Applied term_fx remain until cleared with term_fx::clear_fx
#
# Parameters:
#   $1 - Foreground color (RGB format: "R,G,B") [default: "255,255,255" (white)]
#   $2 - Background color (RGB format: "R,G,B") [default: "0,0,0" (black)]
#   $3 - Blinking (boolean: "true"/"false") [default: "false"]
#   $4 - Bold (boolean: "true"/"false") [default: "false"]
#   $5 - Italic (boolean: "true"/"false") [default: "false"]
#   $6 - Underline (boolean: "true"/"false") [default: "false"]
#   $7 - Strikethrough (boolean: "true"/"false") [default: "false"]
#   $8 - Overlined (boolean: "true"/"false") [default: "false"]
#
# Stdout:
#   Prints an ANSI escape sequence string to standard output that is used to style 
#   Any following text. 
#   
# Stderr
#   Warnings if terminal doesn't support 24 or 8 bit colors
#   
# Returns:
#   0 Always
# Usage Example:
#   # Apply default styling (white on black, no additional formatting)
#   echo -e "$(set_terminal_style)"
#   echo -e "This is default styled text"  # Display the styled text
#   echo -e "\e[0m" # Reset terminal styles after output
#
#   # Custom styling example (red on blue, bold and underlined)
#   echo -e "$(set_terminal_style "255,0,0" "0,0,255" false true false true)"
#   echo -e "This is custom styled text"  # Display the styled text
#   echo -e "\e[0m" # Reset terminal styles after output
#
##########################################################################################
term_fx::set_fx() {
  local fg_color="${1:-""}" # Default foreground color (white)
  local bg_color="${2:-""}"       # Default background color (black)
  local blinking="${3:-false}"         # Default: No blinking
  local bold="${4:-false}"             # Default: Not bold
  local italic="${5:-false}"           # Default: Not italic
  local underline="${6:-false}"        # Default: Not underlined
  local strikethrough="${7:-false}"    # Default: Not strikethrough
  local overlined="${8:-false}"        # Default: Not overlined

  # Begin the escape sequence
  local escape_seq="\e["

  # Set fg color
  if [[ -n "$fg_color" ]]
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
      # Use 24bit (16.7 million colors)
      escape_seq+="48;2;${bg_color}m" # 48;2 denotes 24 bit
    elif [[ $(tput colors) -ge 256 ]]; then
      echo "Fallback to 8bit color terminal" >&2 # Output to stderr
      # Use 8 bit (256) colors
      local 8bit_fg=$(_rgb_to_8bit fg_color)
      escape_seq+="38;5;${8bit_fg}m" # 38;5 denotes 8 bit
    else
      # Use ANSI fallback
      echo "Fallback to ANSI default terminal colors" >&2 # Output to stderr
      local ansi_fg=$(_rgb_to_ansi_fg fg_color)
    fi
  if

  # Set bg color
  if [[ -n "$bg_color" ]]
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
      # Use 24bit (16.7 million colors)
      escape_seq+="48;2;${bg_color}m" # 48;2 denotes 24 bit
    elif [[ $(tput colors) -ge 256 ]]; then
      # Use 8 bit (256) colors
      local 8bit_bg=$(_rgb_to_8bit bg_color)
      escape_seq+="48;5;${8bit_bg}m" # 48;5 denotes 8 bit
    else
      # Use ANSI fallback
      local ansi_bg=$(_rgb_to_ansi_bg bg_color)
      escape_seq+="${ansi_bg}m"
    fi
  if

  # Append attribute settings based on boolean flags
  [[ "$blinking" == "true" ]] && escape_seq+="5;"
  [[ "$bold" == "true" ]] && escape_seq+="1;"
  [[ "$italic" == "true" ]] && escape_seq+="3;"
  [[ "$underline" == "true" ]] && escape_seq+="4;"
  [[ "$strikethrough" == "true" ]] && escape_seq+="9;"
  [[ "$overlined" == "true" ]] && escape_seq+="53;"

  # Remove the last semicolon if it exists and close the sequence
  escape_seq="${escape_seq%;}m"

  # Output the complete escape sequence
  echo -n "$escape_seq"
}

##########################################################################################
# Function: term_fx::hsv_to_rgb
#
# Purpose:
#   Converts a color from HSV (Hue, Saturation, Value) format to RGB (Red, Green, Blue)
#   format. The function takes separate parameters for hue, saturation, and value,
#   with saturation and value as percentages. It ensures that the provided values are 
#   within acceptable ranges and returns the converted color or an error if the input 
#   is invalid.
#
# Usage:
#   hsv_to_rgb h [s] [v]
#
#   Where hue (h) should be in the range [0, 360), and saturation (s) and value (v)
#   should be in the range [0, 100]. Saturation and value are optional and default to 100.
#
# Parameters:
#   $1 - Hue component of the color (0-360)
#   $2 - Saturation component of the color as a percentage (0-100) [optional, default=100]
#   $3 - Value component of the color as a percentage (0-100) [optional, default=100]
#
# Stdout:
#   Prints the RGB components in the format "r,g,b", where each component is an integer
#   from 0 to 255.
#
# Stderr:
#   If the input parameters are out of range, an error message is printed to stderr.
#
# Returns:
#   0 - Success
#   1 - Invalid hue value
#   2 - Invalid saturation or value
#
# Example:
#   rgb_color=$(hsv_to_rgb 360 100 100)
#   echo "RGB color is: $rgb_color"
#
# Notes:
#   Saturation and Value are provided as percentages and internally scaled to the 0-1 range
#   for the HSV to RGB conversion formula. Errors in input parameters are checked and handled.
##########################################################################################
term_fx::hsv_to_rgb() {
    local h=$1
    local s=${2:-100}  # Default saturation to 100 if not provided
    local v=${3:-100}  # Default value to 100 if not provided

    # Validate input ranges
    if (( h < 0 || h >= 360 )); then
        echo "Error: Hue must be between 0 and 359." >&2
        return 1
    fi

    if (( s < 0 || s > 100 || v < 0 || v > 100 )); then
        echo "Error: Saturation and Value must be between 0 and 100." >&2
        return 2
    fi

    # Normalize s and v from 0-100 to 0-1 for the conversion calculations
    s=$(echo "$s / 100" | bc -l)
    v=$(echo "$v / 100" | bc -l)

    local r g b i f p q t
    local h_int=$(($h / 60))

    # Calculate temporary values based on hue position
    local f=$(echo "$h / 60 - $h_int" | bc -l)
    local p=$(echo "$v * (1 - $s)" | bc -l)
    local q=$(echo "$v * (1 - $f * $s)" | bc -l)
    local t=$(echo "$v * (1 - (1 - $f) * $s)" | bc -l)

    # Assign rgb depending on sector of color wheel
    case $h_int in
        0) r=$v; g=$t; b=$p ;;
        1) r=$q; g=$v; b=$p ;;
        2) r=$p; g=$v; b=$t ;;
        3) r=$p; g=$q; b=$v ;;
        4) r=$t; g=$p; b=$v ;;
        5) r=$v; g=$p; b=$q ;;
        *) echo "Invalid hue calculation error" >&2; return 1 ;;
    esac

    # Convert fractional colors to 0-255 range, rounding appropriately
    r=$(printf "%.0f" $(echo "$r * 255" | bc -l))
    g=$(printf "%.0f" $(echo "$g * 255" | bc -l))
    b=$(printf "%.0f" $(echo "$b * 255" | bc -l))

    # Output the RGB string
    echo "$r,$g,$b"
}

