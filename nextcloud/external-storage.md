# Nextcloud External Storage

Nextcloud AIO では、写真本体を Nextcloud のデータディレクトリに直接入れず、Windows HDD上の `D:\home` を外部ストレージとして見せる。

## ホストパス

Windows:

```text
D:\home
```

Docker Desktop / WSL / コンテナ側:

```text
/mnt/d/home
```

この環境では `/run/desktop/mnt/host/d/home` は空に見えたため使わない。

確認:

```bash
docker run --rm -v /mnt/d/home:/test alpine:latest ls -la /test
```

## AIO 起動時の許可パス

`docker/.env`:

```env
NEXTCLOUD_MOUNT=/mnt/d/home
```

## 外部ストレージ対応表

Nextcloud 管理画面で「外部ストレージ」アプリを有効化し、管理者設定から以下を追加する。

```text
/picture            -> /mnt/d/home/picture
/photoframe         -> /mnt/d/home/photoframe
/family             -> /mnt/d/home/family
/ウェディングフォト -> /mnt/d/home/ウェディングフォト
/新婚旅行           -> /mnt/d/home/新婚旅行
```

実運用では `/family` の代わりに `/家族共有` を使ってもよい。

## 「制限する」の意味

Nextcloudの外部ストレージ設定にある「制限する」は、共有リンク設定ではなく、その外部ストレージを **誰のファイル一覧に表示するか** の指定。

例:

```text
/picture
  users: main-user
  groups: admin

/photoframe
  users: main-user, family-user
  groups: admin

/family
  users: main-user, family-user
  groups: admin
```

家族ユーザーに元写真フォルダを見せたくない場合、`/picture` の Applicable Users が `All` になっていないか確認する。

## 権限方針

- `/picture`: 元写真置き場。通常は本人と admin のみにする。
- `/photoframe`: フォトフレーム表示用。家族で編集可でもよい。
- `/family`: 家族共有用。家族で編集可でもよい。

外部ストレージ単位でReadOnlyにすると対象ユーザー全員へ効く可能性がある。ユーザーごとに細かく権限を分けたい場合は、Nextcloud内部フォルダを作り、通常の共有機能で権限管理する方が向いている。
