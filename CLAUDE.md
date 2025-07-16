# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## プロジェクト概要

EsotericWord（難解な単語）は、Lambyフレームワークを使用してAWS Lambda上でサーバーレスデプロイするために設計されたRails 7.2アプリケーションです。難解な日本語の単語を管理するためのCRUDアプリケーションです。

## 主要技術

- **バックエンド**: Ruby 3.2, Rails 7.2
- **データベース**: MySQL 8.x（ブランチ名から現在DynamoDBへの移行作業中）
- **フロントエンド**: Slimテンプレート、Bootstrap 5.3、Stimulus.js、Turbo Rails
- **デプロイメント**: [Lamby](https://lamby.cloud/)経由でAWS Lambda、Dockerでコンテナ化
- **インフラ**: AWS SAM

### 重要な依存関係
- **[Lamby](https://lamby.cloud/)**: RailsアプリケーションをAWS Lambdaで実行するためのアダプター
  - Dockerfileで設定: `CMD ["config/environment.Lamby.cmd"]` (28行目)
  - バージョン: 6.0.1 (Gemfileで確認可能)
  - 公式ドキュメント: https://lamby.cloud/
- **[Crypteia](https://github.com/rails-lambda/crypteia-extension)**: 環境変数をAWS SSMから安全に取得
  - Dockerfileで設定: `COPY --from=ghcr.io/rails-lambda/crypteia-extension-debian:1 /opt /opt` (6行目)
- **[Ridgepole](https://github.com/ridgepole/ridgepole)**: データベーススキーマをRuby DSLで管理
  - スキーマファイル: `db/schemas/` ディレクトリ

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

## 重要な開発ルール

### 技術選定や推奨事項について回答する際は必ず公式ドキュメントを確認すること
- **Lamby関連**: https://lamby.cloud/docs を必ず参照
  - DynamoDB使用時は[Lamby公式推奨のAws::Record](https://lamby.cloud/docs/database)を使用
- **AWS関連**: AWS公式ドキュメントを参照
- **Rails関連**: Rails Guidesを参照

推測や一般的な知識だけで答えず、必ず一次情報源を確認してから回答すること。

### コード実装前の必須確認事項
1. **新しいGemやライブラリを使用する前に**：
   - 公式ドキュメントでAPIと使用方法を確認
   - 特にActiveRecordの代替品（Aws::Record等）は、ActiveRecordとは全く異なるAPIを持つ可能性がある
   - 例: Aws::Recordには`before_save`コールバックは存在しない

2. **実装前チェックリスト**：
   - [ ] 使用するGemの公式ドキュメントを読んだか？
   - [ ] そのGemの基本的な使用例を確認したか？
   - [ ] ActiveRecordの知識をそのまま適用しようとしていないか？
   - [ ] 実際に動作するコードサンプルを参照したか？

3. **Aws::RecordをRailsで使用する際の完全な実装パターン**：
   ```ruby
   class Question
     include Aws::Record
     extend ActiveModel::Naming      # 必須: ルーティングヘルパー対応
     include ActiveModel::Conversion # 必須: フォームヘルパー対応
     # 重要: ActiveModel::Modelは含めない（initializeメソッドが競合するため）
     
     # DynamoDB属性定義（default_valueオプションを使用）
     string_attr :id, hash_key: true, default_value: -> { SecureRandom.uuid }
     string_attr :content
     datetime_attr :created_at, default_value: -> { Time.current }
     datetime_attr :updated_at, default_value: -> { Time.current }
     
     # Rails統合用メソッド
     # persisted?は既にAws::Recordに実装済み（定義不要）
     # 内部実装: !(new_record? || destroyed?)
     
     def to_param
       id  # URLパラメータ生成用
     end
     
     # 初期化はdefault_valueで行うため、initializeのオーバーライドは不要
     
     # 必須: 保存処理
     def save
       self.updated_at = Time.current
       super
     rescue Aws::DynamoDB::Errors::ResourceNotFoundException
       raise "DynamoDB table '#{self.class.table_name}' does not exist."
     end
     
     # ActiveRecordライクなクラスメソッド（実際のAws::Record APIに基づく）
     class << self
       def all
         scan  # 正しい: Aws::Record.scan()が存在
       end
       
       def find(id)
         # 正しい: Aws::Record.find(hash_key: value)形式
         # 重要: 見つからない場合はnilを返す（例外は投げない）
         find(id: id)
       end
       
       def create(attributes = {})
         new(attributes).tap(&:save)
       end
     end
   end
   ```

4. **Aws::Record実際のAPI仕様（vendor/bundleから確認済み）**：
   - **コールバックは一切存在しない**（before_save, after_save等は使えない）
   - **デフォルト値の設定**：`default_value`オプションを使用（initializeをオーバーライドしない）
   - **属性定義**：`string_attr`, `integer_attr`等の専用メソッドを使用
   - **主キー定義**：`hash_key: true`で明示的に指定
   - **実際に存在するクラスメソッド**：
     - `find(opts)` - ハッシュで検索（例: `find(id: "123")`）**見つからない場合はnilを返す（例外は投げない）**
     - `find_all(keys)` - 複数検索
     - `scan(opts = {})` - 全件取得
     - `query(opts)` - 条件検索
     - `update(new_params, opts = {})` - 直接更新
     - `build_query` / `build_scan` - クエリビルダー
   - **存在しないメソッド**：
     - `find_by_id` - 存在しない！
     - `where` - 存在しない！
     - ActiveRecordのメソッドは基本的に存在しない
   - **ActiveRecordとの決定的な違い**：
     - whereメソッドなし（scanまたはqueryを使用）
     - マイグレーションなし（テーブル作成はSDK経由）
     - バリデーションの仕組みが異なる
     - **Rails統合には追加実装が必須**（上記の完全な実装パターン参照）
   - **よくあるエラーと原因**：
     - `undefined method 'model_name'` → ActiveModel::Namingをextendしていない
     - `undefined method 'persisted?'` → persisted?メソッドを実装していない
     - `undefined method 'to_param'` → to_paramメソッドを実装していない
     - フォームがうまく動かない → ActiveModel::Modelをincludeしていない
   - 公式ドキュメント: https://github.com/aws/aws-record-ruby