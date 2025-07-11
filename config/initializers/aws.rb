require "aws-sdk-dynamodb"

# AWS SDK設定をconfig/aws.ymlから読み込む
Aws.config.update(
  Rails.application.config_for(:aws).deep_symbolize_keys
)

# DynamoDBテーブルの作成（開発環境のみ）
if Rails.env.development? || Rails.env.test?
  begin
    dynamodb = Aws::DynamoDB::Client.new
    table_name = ENV["QUESTIONS_TABLE_NAME"] || "questions_#{Rails.env}"

    # テーブルが存在するか確認
    begin
      dynamodb.describe_table(table_name: table_name)
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException
      # テーブルが存在しない場合は作成
      dynamodb.create_table(
        table_name: table_name,
        key_schema: [
          {
            attribute_name: "id",
            key_type: "HASH"
          }
        ],
        attribute_definitions: [
          {
            attribute_name: "id",
            attribute_type: "S"
          },
          {
            attribute_name: "content",
            attribute_type: "S"
          }
        ],
        global_secondary_indexes: [
          {
            index_name: "content_index",
            key_schema: [
              {
                attribute_name: "content",
                key_type: "HASH"
              }
            ],
            projection: {
              projection_type: "ALL"
            },
            provisioned_throughput: {
              read_capacity_units: 5,
              write_capacity_units: 5
            }
          }
        ],
        provisioned_throughput: {
          read_capacity_units: 5,
          write_capacity_units: 5
        }
      )

      Rails.logger.info "Created DynamoDB table: #{table_name}"
    end
  rescue => e
    Rails.logger.warn "DynamoDB initialization error: #{e.message}"
  end
end
