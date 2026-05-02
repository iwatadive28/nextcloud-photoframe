# Recovery

## 前提

このリポジトリだけではNextcloudの完全復元はできない。以下が別途必要。

- `D:\home` の写真データ
- Docker volume / AIO backup
- AIO passphrase
- Nextcloud admin password
- Nextcloud app password
- Tailscaleログイン権限

## Docker環境を再作成する

1. Docker Desktop を起動する。
2. `docker/.env` を作る。

```bash
cp docker/.env.example docker/.env
```

3. `NEXTCLOUD_MOUNT` が実環境の写真パスを指していることを確認する。

```env
NEXTCLOUD_MOUNT=/mnt/d/home
```

4. AIO mastercontainer を起動する。

```bash
cd docker
docker compose --env-file .env up -d
```

5. AIO管理画面を開く。

```text
https://127.0.0.1:8080
```

6. AIOの画面から復元または初期セットアップを進める。

## Tailscale Serve を戻す

Windows PowerShell:

```powershell
.\windows\tailscale-serve.ps1 -TargetPort 11000
tailscale serve status
```

期待:

```text
https://<machine-name>.<tailnet>.ts.net
|-- / proxy http://127.0.0.1:11000
```

## 外部ストレージを戻す

Nextcloud管理画面で [nextcloud/external-storage.md](../nextcloud/external-storage.md) の対応表を設定する。

設定後:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:list
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:verify <mount-id>
docker exec --user www-data nextcloud-aio-nextcloud php occ files:scan --path='<nextcloud-user>/files/photoframe'
```

## Raspberry Pi を戻す

1. Tailscale にログインする。
2. `rclone config` で Nextcloud WebDAV remote を作る。
3. `raspberrypi/setup.md` に沿って `feh`, cron, MATE設定を戻す。

最低限:

```bash
sudo apt update
sudo apt install -y rclone feh unclutter
mkdir -p /home/ubuntu/Pictures/frame
rclone copy nextcloud:photoframe /home/ubuntu/Pictures/frame --progress
```

## トラブルシュート

### Nextcloudから外部ストレージが空に見える

`NEXTCLOUD_MOUNT` と実際のDocker側パスを確認する。

```bash
docker run --rm -v /mnt/d/home:/test alpine:latest ls -la /test
```

### ラズパイがログイン画面に戻る

MATE screensaver と電源管理を確認する。

```bash
sudo -u ubuntu DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus gsettings get org.mate.power-manager sleep-display-ac
sudo -u ubuntu DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus gsettings get org.mate.screensaver lock-enabled
ps -ef | grep -Ei 'mate-screensaver|xscreensaver|light-locker|gnome-screensaver|sleep 3600' | grep -v grep
```

### 輝度が最大に戻る

MATEの `brightness-ac` はraw値ではなくパーセント。

```bash
sudo -u ubuntu DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus gsettings set org.mate.power-manager brightness-ac 40.0
```
