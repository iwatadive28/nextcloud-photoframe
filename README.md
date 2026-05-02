# Nextcloud Photoframe

Windows PC上の Docker Desktop で Nextcloud AIO を動かし、Tailscale 経由で家族用写真クラウドとして使う。Raspberry Pi は Nextcloud の `/photoframe` を定期同期し、公式7インチTouch Displayでフォトフレーム表示する。

このリポジトリは **再現用の設定・手順だけ** を管理する。写真本体、Docker volume、パスワード、app password、AIO passphrase はGit管理しない。

## 構成

```text
Windows 11 PC
  Docker Desktop
  Nextcloud AIO
  HDD: D:\home

Tailscale
  HTTPS URL: https://<machine-name>.<tailnet>.ts.net/
  Serve: https 443 -> http://127.0.0.1:11000

Nextcloud
  /picture     -> /mnt/d/home/picture
  /photoframe  -> /mnt/d/home/photoframe
  /family      -> /mnt/d/home/family

Raspberry Pi
  Ubuntu Desktop / MATE
  rclone
  feh
  /home/ubuntu/Pictures/frame
```

## 重要な方針

- Nextcloud は直接インターネット公開しない。Tailscale tailnet 内だけで使う。
- Nextcloud本体やDBは Docker volume に置く。
- 写真本体は Windows の `D:\home` に置き、Nextcloud 外部ストレージとして見せる。
- Git管理するのは設定テンプレート、スクリプト、復旧手順だけ。
- `D:\home`、Docker volume、`rclone.conf`、app password、AIO passphrase はGit管理しない。

## 初回セットアップ

1. `.env.example` を参考に `docker/.env` を作る。

```bash
cp docker/.env.example docker/.env
```

2. Nextcloud AIO mastercontainer を起動する。

既に `nextcloud-aio-mastercontainer` が動いている環境では、このコマンドは実行しない。現在の状態確認だけでよい。

```bash
docker ps --filter name=nextcloud-aio-mastercontainer
```

新規構築、または既存コンテナを停止・削除して再作成する場合だけ実行する。

```bash
cd docker
docker compose --env-file .env up -d
```

3. AIO管理画面を開く。

```text
https://127.0.0.1:8080
```

4. AIO管理画面のドメイン欄に Tailscale FQDN を入れる。

```text
<machine-name>.<tailnet>.ts.net
```

5. Windows側で Tailscale Serve を設定する。

```powershell
.\windows\tailscale-serve.ps1 -TargetPort 11000
```

6. Nextcloud 管理画面で外部ストレージを設定する。

詳細は [nextcloud/external-storage.md](nextcloud/external-storage.md)。

7. Raspberry Pi 側を設定する。

詳細は [raspberrypi/setup.md](raspberrypi/setup.md)。

## 起動・停止

mastercontainer の起動:

```bash
cd docker
docker compose --env-file .env up -d
```

既存の手動作成済み `nextcloud-aio-mastercontainer` がある場合、同じコンテナ名を使うため `Conflict. The container name "/nextcloud-aio-mastercontainer" is already in use` になる。その場合は、既存コンテナが正なので `compose up` は不要。

状態確認:

```bash
docker ps
docker logs --tail 100 nextcloud-aio-mastercontainer
```

AIO子コンテナはAIO管理画面から起動・停止する。

Nextcloud本体の主なコンテナ:

```text
nextcloud-aio-apache
nextcloud-aio-nextcloud
nextcloud-aio-database
nextcloud-aio-redis
nextcloud-aio-imaginary
nextcloud-aio-notify-push
```

## 現環境の要点

現在の実運用では、AIO mastercontainer は以下の値で起動している。

```text
APACHE_PORT=11000
APACHE_IP_BINDING=127.0.0.1
NEXTCLOUD_MOUNT=/mnt/d/home
```

Docker volume:

```text
nextcloud_aio_mastercontainer
nextcloud_aio_nextcloud
nextcloud_aio_nextcloud_data
nextcloud_aio_database
nextcloud_aio_database_dump
nextcloud_aio_apache
nextcloud_aio_redis
```

## 運用

- 通常運用: [docs/operations.md](docs/operations.md)
- 復旧手順: [docs/recovery.md](docs/recovery.md)
- occ コマンド集: [nextcloud/occ-commands.md](nextcloud/occ-commands.md)

## Windows起動時の自動復帰

この環境では、AIO mastercontainer と子コンテナに restart policy が設定されている。

```text
nextcloud-aio-mastercontainer: always
nextcloud-aio-apache: unless-stopped
nextcloud-aio-nextcloud: unless-stopped
nextcloud-aio-database: unless-stopped
```

Docker Desktop がWindowsサインイン時に起動し、Tailscaleサービスが自動起動していれば、PC再起動後もNextcloudは自動復帰する。

確認:

```powershell
docker inspect nextcloud-aio-mastercontainer --format "{{.HostConfig.RestartPolicy.Name}}"
docker inspect nextcloud-aio-apache --format "{{.HostConfig.RestartPolicy.Name}}"
docker inspect nextcloud-aio-nextcloud --format "{{.HostConfig.RestartPolicy.Name}}"
docker inspect nextcloud-aio-database --format "{{.HostConfig.RestartPolicy.Name}}"

Get-Service Tailscale
tailscale serve status
```
