# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## プロジェクト概要

EsotericWord（難解な単語）は、Lambyフレームワークを使用してAWS Lambda上でサーバーレスデプロイするために設計されたRails 7.2アプリケーションです。難解な日本語の単語を管理するためのCRUDアプリケーションです。

## 主要技術

- **バックエンド**: Ruby 3.2, Rails 7.2
- **データベース**: MySQL 8.x（ブランチ名から現在DynamoDBへの移行作業中）
- **フロントエンド**: Slimテンプレート、Bootstrap 5.3、Stimulus.js、Turbo Rails
- **デプロイメント**: Lamby経由でAWS Lambda、Dockerでコンテナ化
- **インフラ**: AWS SAM

## 必須コマンド

```bash
# 初期セットアップ
./bin/setup

# テスト実行
./bin/test

# Railsサーバーをローカルで起動
./bin/rails server

# リンティング実行
bundle exec rubocop

# データベーススキーマ変更を適用（Ridgepole使用）
bundle exec ridgepole -c config/database.yml -E development --apply -f db/schemas/Schemafile

# AWSへデプロイ
./bin/deploy

# Railsコンソール
./bin/rails console

# Railsコンポーネント生成
./bin/rails generate controller コントローラー名
./bin/rails generate model モデル名
```

## アーキテクチャとコード構成

### MVC構造
- **コントローラー**: `app/controllers/`に配置。管理機能は`Admins::`名前空間下にある
- **モデル**: `app/models/`に配置。現在、単語管理用の`Question`モデルがある
- **ビュー**: `app/views/`に配置、Slimテンプレートエンジンのみを使用

### 主要なアーキテクチャ決定事項
1. **サーバーレスファースト**: 従来のサーバーではなくAWS Lambda上で動作
2. **スキーマ管理**: Railsマイグレーションの代わりにRidgepoleを使用。スキーマ定義は`db/schemas/`にある
3. **環境変数**: AWS SSMパラメータストアに保存、Crypteia経由でアクセス
4. **名前空間の分離**: 管理機能は`Admins::`名前空間下
5. **国際化**: デフォルトロケールは日本語（ja）

### 重要なファイル
- `template.yaml`: LambdaデプロイメントのためのAWS SAM設定
- `db/schemas/Schemafile`: データベーススキーマ定義（Ridgepole形式）
- `config/application.rb`: Rails設定（タイムゾーン: Tokyo、ロケール: ja）
- `Dockerfile`: Lambdaランタイムのコンテナセットアップ

## 開発パターン

### データベーススキーマ変更
従来のRailsマイグレーションは使用しない。代わりに：
1. `db/schemas/`内のスキーマファイルを編集
2. 変更を適用: `bundle exec ridgepole -c config/database.yml -E development --apply -f db/schemas/Schemafile`

### ビューテンプレート
すべてのビューはSlim構文を使用。例：
```slim
.container
  h1 = t('.title')
  = simple_form_for @question do |f|
    = f.input :word
```

### フォーム処理
Bootstrap 5統合のsimple_form gemを使用。フォームは自動的にBootstrapスタイリングが適用される。

### テスト
`./bin/test`でテストを実行。テストファイルは`test/`ディレクトリのRails規約に従う。

## デプロイメント

デプロイメントはコンテナ化されており、AWS SAMを使用：
1. `./bin/deploy`が全体のデプロイプロセスを処理
2. 関数は1792 MBのメモリでVPC内で実行
3. 環境変数はSSMパラメータストアから読み込まれる
4. コンテナイメージはECRに保存される

## 現在の開発コンテキスト

現在のブランチ`replace_rdb_to_dynamo`は、MySQLからDynamoDBへの移行作業が進行中であることを示している。この移行作業を行う際は：
- 既存のQuestionモデル構造を考慮する
- 既存のコントローラーとビューとの互換性を維持する
- RidgepoleはMySQL専用のため、スキーマ管理アプローチを更新する