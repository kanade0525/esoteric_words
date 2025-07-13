# DynamoDB設定
if Rails.env.development? || Rails.env.test?
  # 開発環境とテスト環境ではDynamoDB Localを使用
  Aws.config.update({
    region: ENV["AWS_REGION"] || "ap-northeast-1",
    endpoint: ENV["DYNAMODB_ENDPOINT"] || "http://localhost:8000",
    credentials: Aws::Credentials.new("dummy", "dummy") # ローカルでは認証不要
  })
else
  # 本番環境では通常のAWS設定を使用
  Aws.config.update({
    region: ENV["AWS_REGION"] || "ap-northeast-1"
  })
end
