# This script handles rotation of the screen and related input devices automatically
# using the output of the monitor-sensor command (part of the iio-sensor-proxy package)
# for sway.
# The target screen and input device names should be configured in the below variables.
# Note: input devices using the libinput driver (e.g. touchscreens) should be included
# in the WAYLANDINPUT array.  
#
# You can get a list of input devices with the `swaymsg -t output` command.
#
# This scritp was frok from https://gitlab.com/snippets/1793649 by Fishonadish 


SCREEN="eDP-1"
WAYLANDINPUT=("5075:22237:USB2.0_HD_UVC_WebCam:_USB2.0_HD"
  "1267:11394:ELAN9008:00_04F3:2C82"
  "1267:11394:ELAN9008:00_04F3:2C82_Stylus"
  "1267:12440:ELAN1201:00_04F3:3098_Mouse")

function rotate_ms {
    case $1 in
        "normal")
            rotate 0
            ;;
        "right-up")
            rotate 90
            ;;
        "bottom-up")
            rotate 180
            ;;
        "left-up")
            rotate 270
            ;;
    esac
}

function rotate {

    TARGET_ORIENTATION=$1

    echo "Rotating to" $TARGET_ORIENTATION

    swaymsg output $SCREEN transform $TARGET_ORIENTATION

    for i in "${WAYLANDINPUT[@]}" 
    do
        swaymsg input "$i" map_to_output "$SCREEN"
    done

}

while IFS='$\n' read -r line; do
    rotation="$(echo $line | sed -En "s/^.*orientation changed: (.*)/\1/p")"
    [[ !  -z  $rotation  ]] && rotate_ms $rotation
done < <(stdbuf -oL monitor-sensor)
