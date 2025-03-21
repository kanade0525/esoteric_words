create_table :questions, force: :cascade, charset: 'utf8mb4', collation: 'utf8mb4_bin', options: 'ENGINE=InnoDB ROW_FORMAT=DYNAMIC' do |t|
  t.string  :content, null: false, default: ''

  t.index :content, name: 'index_questions_on_content'
end
