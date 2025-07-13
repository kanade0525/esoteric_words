class Question
  include Aws::Record
  extend ActiveModel::Naming
  # ActiveModel::Modelは含めない（initializeメソッドの競合を避けるため）
  # simple_formに必要な最小限のモジュールのみを含める
  include ActiveModel::Conversion

  set_table_name "esoteric_words_questions_#{Rails.env}"

  string_attr :id, hash_key: true, default_value: -> { SecureRandom.uuid }
  string_attr :content
  datetime_attr :created_at, default_value: -> { Time.current }
  datetime_attr :updated_at, default_value: -> { Time.current }

  # ActiveRecordライクなメソッドを追加
  class << self
    def all
      scan
    end

    def order(field)
      # DynamoDBではScanの結果をメモリ上でソートする必要がある
      all.to_a.sort_by { |item| item.send(field) }
    end

    def create(attributes = {})
      new(attributes).tap(&:save)
    end

    def find(id)
      # Aws::Recordのfindメソッドは見つからない場合nilを返す（例外は投げない）
      super(id: id)
    end
  end

  # Rails統合用メソッド
  # persisted?はAws::Recordに既に実装されているので定義不要
  # 正しい実装: !(new_record? || destroyed?)
  
  def to_param
    id
  end

  # インスタンスメソッド
  def save
    # 更新時のタイムスタンプを設定
    self.updated_at = Time.current
    super
  rescue Aws::DynamoDB::Errors::ResourceNotFoundException
    # テーブルが存在しない場合のエラーハンドリング
    raise "DynamoDB table '#{self.class.table_name}' does not exist. Run 'rails db:create' to create it."
  end

  def update(attributes)
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
    save
  end

  def destroy
    delete!
  end
end
