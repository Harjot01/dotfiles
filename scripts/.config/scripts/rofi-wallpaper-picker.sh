#!/bin/bash

WALLPAPER_DIR="$HOME/.config/backgrounds/"
THUMB_DIR="$HOME/.cache/wall_thumbnails"

mkdir -p "$THUMB_DIR"

# Generate thumbnails using ImageMagick v7
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
    [ -e "$img" ] || continue
    base=$(basename "$img")
    thumb="$THUMB_DIR/${base}.png"
    if [ ! -f "$thumb" ]; then
        magick "$img" -resize 200x200^ -gravity center -extent 200x200 "$thumb"
    fi
done

# Build Rofi input with icon markup
choices=""
for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
    [ -e "$img" ] || continue
    base=$(basename "$img")
    thumb="$THUMB_DIR/${base}.png"
    choices+="$base\x00icon\x1f$thumb\n"
done

# Show Rofi with icons
chosen=$(echo -e "$choices" | rofi -dmenu -markup -show-icons -theme ~/.config/rofi/wallpaper-grid.rasi -p " ")

if [[ -n "$chosen" ]]; then
    wallpaper="$WALLPAPER_DIR/$chosen"

    # Ensure swww-daemon is running
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon &
        sleep 0.5
    fi

    # Change wallpaper
    swww img "$wallpaper" --transition-type wave --transition-duration 2

    # Generate Pywal color scheme
    wal -i "$wallpaper" --cols16 --saturate 0.9

    # Reload Kitty colors
    kitty @ set-colors --all ~/.cache/wal/colors-kitty.conf

    pkill swaync
    swaync
    # Optionally reload Rofi if it uses wal colors
    # This is not always necessary unless you dynamically source ~/.cache/wal/colors-rofi-dark.rasi
fi

