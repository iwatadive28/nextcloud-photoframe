#!/usr/bin/env bash
set -euo pipefail

GUI_USER="${GUI_USER:-ubuntu}"
GUI_UID="${GUI_UID:-1000}"
DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/${GUI_UID}/bus}"

run_gsettings() {
  sudo -u "$GUI_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" gsettings "$@"
}

echo "Applying GNOME/MATE power and screensaver settings for user: $GUI_USER"

# GNOME-compatible keys present on this Ubuntu Desktop image.
run_gsettings set org.gnome.desktop.session idle-delay 0
run_gsettings set org.gnome.desktop.screensaver lock-enabled false
run_gsettings set org.gnome.desktop.screensaver lock-delay 0
run_gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
run_gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
run_gsettings set org.gnome.settings-daemon.plugins.power idle-dim false

# MATE power manager and screensaver keys.
run_gsettings set org.mate.power-manager sleep-display-ac 0
run_gsettings set org.mate.power-manager sleep-computer-ac 0
run_gsettings set org.mate.power-manager lock-use-screensaver false
run_gsettings set org.mate.power-manager lock-blank-screen false
run_gsettings set org.mate.power-manager lock-suspend false
run_gsettings set org.mate.power-manager idle-dim-ac false
run_gsettings set org.mate.power-manager brightness-ac 40.0
run_gsettings set org.mate.screensaver idle-activation-enabled false
run_gsettings set org.mate.screensaver lock-enabled false
run_gsettings set org.mate.screensaver lock-delay 0

# Prevent D-Bus activation from starting /usr/bin/mate-screensaver --no-daemon.
sudo -u "$GUI_USER" mkdir -p "/home/${GUI_USER}/.local/share/dbus-1/services"
sudo -u "$GUI_USER" tee "/home/${GUI_USER}/.local/share/dbus-1/services/org.mate.ScreenSaver.service" >/dev/null <<'EOF'
[D-BUS Service]
Name=org.mate.ScreenSaver
Exec=/bin/sleep 3600
EOF

echo "Done. Reboot and verify with:"
echo "  ps -ef | grep -Ei 'mate-screensaver|xscreensaver|light-locker|gnome-screensaver|sleep 3600' | grep -v grep"
echo "  cat /sys/class/backlight/rpi_backlight/brightness"
