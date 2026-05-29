#!/bin/bash
# Generate Play Store Feature Graphic (1024x500)
# Requires: ImageMagick (brew install imagemagick)

OUTPUT="docs/screenshots/feature_graphic.png"
ICON="assets/icon/app_icon.png"

FONT_TITLE="/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_BODY="/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_SMALL="/System/Library/Fonts/Supplemental/Arial.ttf"

magick \
  -size 1024x500 \
  xc:'#F5F5F5' \
  \( "$ICON" -resize 280x280 \) \
  -gravity west -geometry +80+0 -composite \
  -fill '#0D0D0D' -font "$FONT_TITLE" -pointsize 52 -gravity west \
  -annotate +400-20 "Your Printer" \
  -fill '#FE7114' -font "$FONT_BODY" -pointsize 24 -gravity west \
  -annotate +400+40 "Print anything, anywhere." \
  -fill '#9E9E9E' -font "$FONT_SMALL" -pointsize 14 -gravity southWest \
  -annotate +80+20 "Available on Google Play" \
  "$OUTPUT"

echo "✅ Feature graphic → $OUTPUT"
