# frozen_string_literal: true

create_table 'recipe_categories', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name'
  t.string 'name_slug'
  t.bigint 'recipe_category_id'
  t.timestamps
end

create_table 'user_follows', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' do |t|
  t.bigint  'user_id_from', unsigned: true, null: false
  t.bigint  'user_id_to',   unsigned: true, null: false
  t.boolean 'is_blocked',   null: false, default: false
  t.boolean 'is_muted',     null: false, default: false
  t.timestamps
end
add_index       'user_follows', %w[user_id_from user_id_to], name: 'idx_user_follows_on_user_id_from_and_user_id_to', unique: true
add_index       'user_follows', %w[user_id_to],              name: 'idx_user_follows_on_user_id_to'
add_foreign_key 'user_follows', 'users',                     name: 'fk_user_follows_1', column: 'user_id_from'
add_foreign_key 'user_follows', 'users',                     name: 'fk_user_follows_2', column: 'user_id_to'

create_table 'user_profiles', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint  'user_id',          null: false, unsigned: true
  t.string  'name',             null: false, default: '', limit: 25
  t.date    'birth_date'
  t.integer 'housework_career', unsigned: true
  t.string  'image',            null: false, default: ''
  t.string  'description',      limit: 120
  t.string  'website_url',      limit: 100
  t.timestamps
end
add_index       'user_profiles', %w[user_id],     name: 'idx_user_profiles_on_user_id'
add_foreign_key 'user_profiles', 'users',         name: 'fk_user_profiles_1'

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
