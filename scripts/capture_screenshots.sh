#!/bin/bash
# Play Store Screenshot Capture Script
# Run your app on an emulator/device, then run this script.
# Press Enter after navigating to each screen.

DEVICE="emulator-5554"
OUTPUT_DIR="docs/screenshots"

mkdir -p "$OUTPUT_DIR"

capture() {
  local name=$1
  local label=$2
  echo ""
  echo "📸  [$name] $label"
  echo "    Navigate to this screen, then press Enter..."
  read -r
  adb -s "$DEVICE" exec-out screencap -p > "$OUTPUT_DIR/${name}.png"
  echo "    ✅ Captured → $OUTPUT_DIR/${name}.png"
}

echo "============================================"
echo "  Play Store Screenshot Capture"
echo "============================================"
echo ""
echo "Make sure your app is running on device: $DEVICE"
echo ""

capture "screenshot_01" "Home / Main Screen"
capture "screenshot_02" "Print Configuration"
capture "screenshot_03" "Connection / Bluetooth"
capture "screenshot_04" "Settings"

echo ""
echo "============================================"
echo "  All done! Check docs/screenshots/"
echo "============================================"
ls -lh "$OUTPUT_DIR"/screenshot_*.png 2>/dev/null
