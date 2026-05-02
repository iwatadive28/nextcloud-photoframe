# Operations

## 日常確認

Windows / Docker:

```bash
docker ps
docker ps --filter name=nextcloud-aio-mastercontainer
docker logs --tail 50 nextcloud-aio-apache
docker logs --tail 50 nextcloud-aio-nextcloud
```

このリポジトリの `docker/compose.yml` は再現用。既存環境では `nextcloud-aio-mastercontainer` がすでに手動作成済みの場合がある。その状態で `docker compose up -d` すると、同じコンテナ名の衝突で失敗する。

```text
Conflict. The container name "/nextcloud-aio-mastercontainer" is already in use
```

この場合は異常ではない。既存コンテナをそのまま使う。

Tailscale Serve:

```powershell
Get-Service Tailscale
tailscale serve status
```

Nextcloud:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ status
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:list
```

Raspberry Pi:

```bash
tailscale status
tail -n 50 /home/ubuntu/photoframe-rclone.log
ls -lh /home/ubuntu/Pictures/frame | head
ps -ef | grep -Ei 'feh|rclone|mate-screensaver|sleep 3600' | grep -v grep
```

## PC再起動後の自動起動

この環境では restart policy は以下。

```text
nextcloud-aio-mastercontainer: always
nextcloud-aio-apache: unless-stopped
nextcloud-aio-nextcloud: unless-stopped
nextcloud-aio-database: unless-stopped
```

確認:

```powershell
docker inspect nextcloud-aio-mastercontainer --format "{{.HostConfig.RestartPolicy.Name}}"
docker inspect nextcloud-aio-apache --format "{{.HostConfig.RestartPolicy.Name}}"
docker inspect nextcloud-aio-nextcloud --format "{{.HostConfig.RestartPolicy.Name}}"
docker inspect nextcloud-aio-database --format "{{.HostConfig.RestartPolicy.Name}}"
```

Windows側では Docker Desktop の以下をONにしておく。

```text
Docker Desktop
  Settings
    General
      Start Docker Desktop when you sign in
```

TailscaleはWindowsサービスとして起動する。

```powershell
Get-Service Tailscale
tailscale serve status
```

PC再起動後の確認:

```powershell
docker ps --filter name=nextcloud-aio
tailscale serve status
Get-Service Tailscale
```

ブラウザまたはスマホから Tailscale URL の Nextcloud が開ければOK。

## 写真追加

1. Nextcloud の `/photoframe` に写真を追加する。
2. Raspberry Pi のcronが10分以内に `rclone copy` する。
3. `feh` のスライドショーが次の切り替えタイミングで表示する。

即時同期:

```bash
rclone copy nextcloud:photoframe /home/ubuntu/Pictures/frame --progress
```

## 外部ストレージ変更後

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:list
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:verify <mount-id>
docker exec --user www-data nextcloud-aio-nextcloud php occ files:scan --path='<nextcloud-user>/files/<mount-name>'
```

## アップデート

Nextcloud AIO はAIO管理画面からアップデートする。作業前に以下を確認する。

```bash
docker ps
docker volume ls | grep nextcloud_aio
```

写真本体は `D:\home` にある。AIO更新と写真本体は別。

## バックアップ方針

- `D:\home`: 写真本体。Windows側の通常バックアップ対象。
- Docker volumes: Nextcloud DB、appdata、AIO設定。Docker Desktop / AIO のバックアップ機能で保護する。
- このリポジトリ: 再現手順と設定テンプレート。Gitで管理する。
