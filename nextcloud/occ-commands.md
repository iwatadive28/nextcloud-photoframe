# occ Commands

Nextcloud AIO の occ は `nextcloud-aio-nextcloud` コンテナ内で実行する。

## 基本

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ status
docker exec --user www-data nextcloud-aio-nextcloud php occ app:list
```

## 外部ストレージ

一覧:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:list
```

検証:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:verify <mount-id>
```

Applicable Users / Groups の確認:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:list --output=json_pretty
```

Applicable Users の追加例:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:applicable <mount-id> --add-user=<user>
docker exec --user www-data nextcloud-aio-nextcloud php occ files_external:applicable <mount-id> --add-group=admin
```

## ファイルスキャン

外部ストレージ追加後、必要に応じてスキャンする。

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files:scan --path='<nextcloud-user>/files/picture'
docker exec --user www-data nextcloud-aio-nextcloud php occ files:scan --path='<nextcloud-user>/files/photoframe'
```

全ユーザーをスキャンする場合:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ files:scan --all
```

写真が多い場合は時間がかかる。実運用では `/picture` のスキャンで数万ファイル、数分程度かかった。

## メンテナンス

メンテナンスモード確認:

```bash
docker exec --user www-data nextcloud-aio-nextcloud php occ maintenance:mode
```

ログ確認:

```bash
docker logs --tail 100 nextcloud-aio-nextcloud
docker logs --tail 100 nextcloud-aio-apache
docker logs --tail 100 nextcloud-aio-database
```
