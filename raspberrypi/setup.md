# Raspberry Pi Setup

対象:

```text
Raspberry Pi
Ubuntu Desktop / MATE
公式7インチTouch Display
GUI user: ubuntu
```

## パッケージ

```bash
sudo apt update
sudo apt install -y rclone feh unclutter
```

## Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
tailscale status
```

Windows側のNextcloudマシンが見えればOK。

## rclone

```bash
rclone config
```

設定例:

```text
n) New remote
name> nextcloud
Storage> webdav
url> https://<machine-name>.<tailnet>.ts.net/remote.php/dav/files/<nextcloud-user>/
vendor> nextcloud
user> <nextcloud-user>
password> <app-password>
bearer_token> 空Enter
```

Nextcloudの通常パスワードではなく、アプリパスワードを使う。

接続確認:

```bash
rclone lsd nextcloud:
rclone lsf nextcloud:photoframe | head
```

## 写真同期

```bash
mkdir -p /home/ubuntu/Pictures/frame
rclone copy nextcloud:photoframe /home/ubuntu/Pictures/frame --dry-run
rclone copy nextcloud:photoframe /home/ubuntu/Pictures/frame --progress
```

cron:

```bash
crontab -e
```

`raspberrypi/rclone-cron.example` の内容を追加する。

ログ確認:

```bash
tail -n 50 /home/ubuntu/photoframe-rclone.log
```

## フォトフレーム起動

```bash
mkdir -p /home/ubuntu/bin
cp raspberrypi/start-photoframe.sh /home/ubuntu/bin/start-photoframe.sh
chmod +x /home/ubuntu/bin/start-photoframe.sh
DISPLAY=:0 /home/ubuntu/bin/start-photoframe.sh
```

このリポジトリをラズパイにcloneしていない場合は、`start-photoframe.sh` の内容を同じパスに配置する。

## GUIログイン後の自動起動

```bash
mkdir -p /home/ubuntu/.config/autostart
nano /home/ubuntu/.config/autostart/photoframe.desktop
```

```ini
[Desktop Entry]
Type=Application
Name=Photoframe
Exec=/home/ubuntu/bin/start-photoframe.sh
X-GNOME-Autostart-enabled=true
```

## スクリーンロック・輝度

MATE設定を適用する。

```bash
sudo bash raspberrypi/mate-settings.sh
```

手動で確認:

```bash
sudo -u ubuntu DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus gsettings get org.mate.power-manager sleep-display-ac
sudo -u ubuntu DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus gsettings get org.mate.power-manager brightness-ac
ps -ef | grep -Ei 'mate-screensaver|xscreensaver|light-locker|gnome-screensaver|sleep 3600' | grep -v grep
cat /sys/class/backlight/rpi_backlight/brightness
cat /sys/class/backlight/rpi_backlight/actual_brightness
```

期待値:

```text
sleep-display-ac: 0
brightness-ac: 40.0
brightness: 102 前後
actual_brightness: 102 前後
mate-screensaver は起動しない
sleep 3600 は表示されてもOK
```
