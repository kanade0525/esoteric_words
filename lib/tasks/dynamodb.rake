namespace :db do
  desc "Create DynamoDB tables"
  task create: :environment do
    puts "Creating DynamoDB tables..."

    table_name = "esoteric_words_questions_#{Rails.env}"

    begin
      # テーブルが既に存在するか確認
      dynamodb = Aws::DynamoDB::Client.new
      dynamodb.describe_table(table_name: table_name)
      puts "Table #{table_name} already exists."
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
          }
        ],
        billing_mode: "PAY_PER_REQUEST"
      )

      puts "Table #{table_name} created successfully."

      # テーブルが作成されるまで待機
      puts "Waiting for table to become active..."
      dynamodb.wait_until(:table_exists, table_name: table_name)
      puts "Table is now active."
    end
  end

  desc "Drop DynamoDB tables"
  task drop: :environment do
    puts "Dropping DynamoDB tables..."

    table_name = "esoteric_words_questions_#{Rails.env}"

    begin
      dynamodb = Aws::DynamoDB::Client.new
      dynamodb.delete_table(table_name: table_name)
      puts "Table #{table_name} dropped successfully."
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException
      puts "Table #{table_name} does not exist."
    end
  end

  desc "Recreate DynamoDB tables"
  task reset: [ :drop, :create ]
end
