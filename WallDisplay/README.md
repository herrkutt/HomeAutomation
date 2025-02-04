# Raspberry Pi Touch Display Control

This project automates the control of a Raspberry Pi touch display to turn off at specific times, reactivate on touch input, and turn on permanently during designated hours.

## Features
- **Scheduled Display Control:**
  - Turns off the display at 11 PM.
  - Turns on the display permanently at 6 AM.
- **Touch-Based Reactivation:**
  - After 11 PM, the display is turned off but can be reactivated by touch.
  - The display stays on for 5 minutes (configurable) after touch input before turning off again.

---

## Prerequisites
- Raspberry Pi running Raspberry Pi OS.
- External monitor connected via HDMI.
- Touch-enabled display.

---

## Installation

### 1. Identify the Touch Device
Run the following command to find your touch input device:
```bash
ls /dev/input/event*
```
Use `evtest` to determine which device corresponds to the touch input:
```bash
sudo apt install evtest
sudo evtest
```
Select the appropriate input device (e.g., `/dev/input/event0`).

### 2. Create the Touch Monitoring Script

Create the script at `/usr/local/bin/touch_monitor.sh`:
```bash
sudo nano /usr/local/bin/touch_monitor.sh
```

Add the following content, updating the `TOUCH_DEVICE` path to match your device:
```bash
#!/bin/bash

TOUCH_DEVICE="/dev/input/event0"  # Update with your touch input device path
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
```

Save the file and exit.

### 3. Make the Script Executable
```bash
sudo chmod +x /usr/local/bin/touch_monitor.sh
```

### 4. Set Up Cron Jobs
Edit the crontab to schedule display control:
```bash
crontab -e
```
Add the following lines:
```bash
# Turn off the display and start touch monitoring at 11 PM
0 23 * * * /usr/local/bin/touch_monitor.sh &

# Turn on the display permanently at 6 AM and stop monitoring
0 6 * * * /usr/bin/vcgencmd display_power 1 && pkill -f touch_monitor.sh
```

Save and exit the crontab.

### 5. Reboot the Raspberry Pi
```bash
sudo reboot
```

---

## Configuration
- **Adjust Touch Timeout:** Modify the `sleep 300` line in the script to change how long the display stays on after a touch event.
- **Change Schedule:** Update the cron jobs in `crontab` to change when the display turns off or on.
- **Log Location:** Logs are stored in `/var/log/touch_display.log`.

---

## Troubleshooting
1. **Script not running:** Ensure the script is executable (`chmod +x /usr/local/bin/touch_monitor.sh`).
2. **Touch events not detected:** Verify the correct touch device is specified in the script (`/dev/input/eventX`).
3. **Cron jobs not executing:** Check the cron service status:
   ```bash
   sudo systemctl status cron
   ```

---

## License
This project is provided under the MIT License.

