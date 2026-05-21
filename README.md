# 新幹線予約システム

Ruby on Rails を用いて開発する、新幹線の座席予約を模した Web アプリケーションである。  
利用者・駅員・運行管理者の3ロールを持ち、便検索、座席予約、発券管理、運行管理までを扱う。

---

## 概要

本システムは、東京〜新大阪間を走行する新幹線を想定し、  
駅・日付・時刻を指定した便検索から、座席選択・予約・発券状態管理までを一貫して行うことを目的とする。

---

## 主な機能

- 会員登録・ログイン
- 便検索（駅・日付・時刻指定）
- 座席選択（指定席／グリーン車／ファビュラスルーム）
- 予約確定・予約確認
- 利用者：予約・自己予約削除（未発券のみ）
- 駅員：代理予約・利用者検索・予約の詳細確認・発券状態管理
- 運行管理者：便追加・運行管理

## 技術スタック

- Ruby: 3.1.6
- Ruby on Rails: 7.0.10
- Database: SQLite3
- Frontend: Rails View (ERB)
- 開発環境:
  - Docker
  
---

## Docker 起動方法

Docker が入っている環境で、以下のコマンドを実行する。

```bash
docker compose up --build
```

起動後、ブラウザで以下にアクセスする。

```text
http://localhost:3000
```

初回起動時は `db:prepare` により SQLite データベースの作成、マイグレーション、seed データ投入を行う。

### 確認用アカウント

| ロール | ログインID | パスワード |
| --- | --- | --- |
| 利用者 | `test_taro` | `Abc123!` |
| 駅員 | `staff_admin` | `StaffAdmin1234$` |
| 運行管理者 | `operator_admin` | `OperatorAdmin1234$` |

### データを初期化したい場合

```bash
docker compose run --rm app bin/rails db:reset
docker compose up
```

---

## 設計ドキュメント

詳細なテストケースや設計元資料は外部ドキュメントにて管理している。

- システム概要・業務ルール: docs/overview.md
- ER図: docs/er.md
- テスト方針・観点: docs/test.md
