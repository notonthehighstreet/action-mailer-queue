ActiveRecord::Schema.define :version => 0 do
  create_table :emails, :force => true do |t|
    t.column :id,                       :integer
    t.column :from,                     :string
    t.column :to,                       :string
    t.column :subject,                  :string
    t.column :content,                  :longblob
    t.column :message_id,               :string
    t.column :sent,                     :boolean, :default => false, :null => false
    t.column :attempts,                 :integer, :default => 0, :null => false
    t.column :last_error,               :string
    t.column :priority,                 :integer, :default => 10, :null => false
    t.column :last_attempt_at,          :datetime
    t.column :sent_at,                  :datetime
    t.column :created_at,               :datetime
    t.column :updated_at,               :datetime
  end
end
