class Question
  include Aws::Record

  set_table_name ENV["QUESTIONS_TABLE_NAME"] || "questions_#{Rails.env}"

  string_attr :id, hash_key: true
  string_attr :content
  datetime_attr :created_at
  datetime_attr :updated_at

  global_secondary_index(
    :content_index,
    hash_key: :content,
    projection: {
      projection_type: "ALL"
    }
  )

  private

  def set_timestamps
    self.updated_at = Time.current
    self.created_at ||= Time.current
  end

  class << self
    def create!(attributes = {})
      attributes[:id] ||= SecureRandom.uuid
      attributes[:created_at] ||= Time.current
      attributes[:updated_at] ||= Time.current
      question = new(attributes)
      question.save!
      question
    end

    def all
      scan
    end

    def find(id)
      find_by_id(id)
    end

    def find_by_id(id)
      query(
        key_condition_expression: "id = :id",
        expression_attribute_values: { ":id" => id }
      ).first || raise(ActiveRecord::RecordNotFound, "Couldn't find Question with id=#{id}")
    end

    def destroy_all
      scan.each(&:delete!)
    end
  end

  public

  def save
    save!
    true
  rescue => e
    Rails.logger.error "Failed to save Question: #{e.message}"
    false
  end

  def save!
    set_timestamps
    # 新規レコードの場合はIDを生成
    self.id ||= SecureRandom.uuid
    
    # DynamoDBに直接保存
    dynamodb_client = Aws::DynamoDB::Client.new(
      region: ENV['AWS_REGION'] || 'ap-northeast-1',
      endpoint: ENV['DYNAMODB_ENDPOINT'] || 'http://localhost:8000',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'] || 'dummy',
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] || 'dummy'
    )
    
    # Aws::Recordの形式でアイテムを準備
    item = {
      'id' => self.id,
      'content' => self.content,
      'created_at' => self.created_at&.iso8601,
      'updated_at' => self.updated_at&.iso8601
    }
    
    dynamodb_client.put_item(
      table_name: self.class.table_name,
      item: item
    )
    self
  rescue => e
    Rails.logger.error "Failed to save Question: #{e.message}"
    raise e
  end

  def update(attributes)
    attributes.each { |key, value| send("#{key}=", value) }
    save
  end

  def update!(attributes)
    attributes.each { |key, value| send("#{key}=", value) }
    save!
  end

  def destroy
    delete!
  end

  public

  def persisted?
    !id.nil? && !new_record?
  end

  def new_record?
    id.nil?
  end

  # Railsフォームヘルパー用のmodel_nameメソッド
  def self.model_name
    ActiveModel::Name.new(self, nil, "Question")
  end

  # Railsルーティング用のto_paramメソッド
  def to_param
    id
  end

  # Railsフォームヘルパー用のインスタンスメソッドmodel_name
  def model_name
    self.class.model_name
  end

  # Railsフォームヘルパー用のto_keyメソッド
  def to_key
    persisted? ? [id] : nil
  end

  # Railsフォームヘルパー用のto_modelメソッド
  def to_model
    self
  end
end
