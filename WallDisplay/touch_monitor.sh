#!/bin/bash

TOUCH_DEVICE="/dev/input/event0"  # Update to your touch device path
DISPLAY_ON_COMMAND="/usr/bin/vcgencmd display_power 1"
DISPLAY_OFF_COMMAND="/usr/bin/vcgencmd display_power 0"
LOG_FILE="/var/log/touch_display.log"

# Initial display off
$DISPLAY_OFF_COMMAND
echo "$(date): Monitoring touch events..." >> "$LOG_FILE"

# Monitor touch events and turn on display if touched
while true; do
    if evtest --grab "$TOUCH_DEVICE" | grep -q "SYN_REPORT"; then
        echo "$(date): Touch detected, turning on display." >> "$LOG_FILE"
        $DISPLAY_ON_COMMAND

        # Wait for a period of inactivity before turning off display again
        sleep 300  # 5 minutes (adjust as needed)

        echo "$(date): No activity, turning off display." >> "$LOG_FILE"
        $DISPLAY_OFF_COMMAND
    fi
done
