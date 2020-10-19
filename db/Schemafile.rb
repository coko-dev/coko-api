# frozen_string_literal: true

create_table 'recipe_categories', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name'
  t.string 'name_slug'
  t.bigint 'recipe_category_id'
  t.timestamps
end

create_table 'users', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string   'code',                   null: false, default: ''
  t.string   'api_token',              null: false, default: ''
  t.string   'firebase_id_token',      null: false, default: ''
  t.string   'firebase_refresh_token', null: false, default: ''
  t.bigint   'kitchen_id',             unsigned: true
  t.integer  'status_id',              null: false, unsigned: true, default: 1, comment: '{ private: 1, published: 2, official: 3 }'
  t.string   'email'
  t.string   'encrypted_password',     null: false, default: ''
  t.integer  'following_count',        null: false, unsigned: true, default: 0
  t.integer  'follower_count',         null: false, unsigned: true, default: 0
  t.datetime 'last_sign_in_at'
  t.timestamps
end
add_index 'users', %w[code],  name: 'idx_users_on_code',  unique: true
add_index 'users', %w[email], name: 'idx_users_on_email', unique: true
