# frozen_string_literal: true

create_table 'kitchens', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',          null: false, default: 'My Kitchen'
  t.boolean 'is_subscriber', null: false, default: false
  t.integer 'status_id',     null: false, unsigned: true, default: 1, comment: '{ private: 1, published: 2, official: 3, blacked: 4 }'
  t.bigint  'owner_user_id', null: false, unsigned: true
  t.timestamps
end
add_index       'kitchens', %w[owner_user_id], name: 'idx_kitchen_on_owner_user_id'
add_foreign_key 'kitchens', 'users',           name: 'fk_kitchens_1', column: 'owner_user_id'

create_table 'kitchen_joins', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.integer  'code',       null: false, unsigned: true
  t.bigint   'kitchen_id', null: false, unsigned: true
  t.integer  'status_id',  null: false, default: 1, comment: '{ open: 1, closed: 2 }'
  t.datetime 'close_at',   null: false
  t.timestamps
end
add_index       'kitchen_joins', %w[kitchen_id], name: 'idx_kitchen_join_on_kitchen_id'
add_foreign_key 'kitchen_joins', 'kitchens',     name: 'fk_kitchen_1'

create_table 'products', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',                null: false
  t.string  'name_hira'
  t.string  'image',               null: false, default: ''
  t.bigint  'product_category_id', null: false, unsigned: true
  t.bigint  'author_id',           null: false, unsigned: true
  t.integer 'status_id',           null: false, unsigned: true, default: 1, comment: '{ published: 1, hidden: 2 }'
  t.timestamps
end

create_table 'product_categories', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name',                     null: false
  t.string 'name_slug',                null: false
  t.bigint 'product_category_id_from', null: false, default: 0, unsigned: true
  t.timestamps
end

create_table 'recipes', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',         null: false
  t.bigint  'author_id',    null: false, unsigned: true
  t.integer 'status_id',    null: false, unsigned: true, default: 1, comment: '{ published: 1, hidden: 2 }'
  t.string  'image',        null: false, default: ''
  t.integer 'cooking_time', null: false, default: 30
  t.string  'description',  null: false, default: ''
  t.timestamps
end

create_table 'recipe_categories', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name',                    null: false
  t.string 'name_slug',               null: false
  t.bigint 'recipe_category_id_from', null: false, default: 0, unsigned: true
  t.timestamps
end
add_index       'recipe_categories', %w[recipe_category_id_from], name: 'idx_recipe_categories_on_recipe_category_id_from'
add_foreign_key 'recipe_categories', 'recipe_categories',         name: 'fk_recipe_categories_1', column: 'recipe_category_id_from'

create_table 'recipe_keywords', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',       null: false
  t.string  'author_id',  null: false, unsigned: true
  t.boolean 'is_blacked', null: false, default: false
  t.timestamps
end

create_table 'recipe_keyword_lists', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'recipe_id',         null: false, unsigned: true
  t.bigint 'recipe_keyword_id', null: false, unsigned: true
  t.timestamps
end

create_table 'recipe_products', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' do |t|
  t.bigint 'recipe_id',  null: false, unsigned: true
  t.bigint 'product_id', null: false, unsigned: true
  t.string 'volume',     null: false, default: ''
  t.string 'note',       default: ''
  t.timestamps
end

create_table 'recipe_records', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'user_id',   null: false, unsigned: true
  t.bigint 'recipe_id', null: false, unsigned: true
  t.text   'body'
  t.timestamps
end

create_table 'recipe_record_images', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'recipe_record_id', null: false, unsigned: true
  t.string 'image',            null: false, default: ''
  t.timestamps
end

create_table 'recipe_sections', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint  'recipe_id',   null: false, unsigned: true
  t.integer 'status_id',   null: false, unsigned: true, default: 1, comment: '{ introduced: 1, advised: 2 }'
  t.text    'body',        null: false
  t.string  'image'
  t.timestamps
end

create_table 'recipe_steps', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' do |t|
  t.bigint  'recipe_id',   null: false, unsigned: true
  t.integer 'sort_order',  null: false, unsigned: true
  t.text    'body',        null: false, default: ''
  t.string  'image'
  t.timestamps
end

create_table 'user_follows', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' do |t|
  t.bigint  'user_id_from', null: false, unsigned: true
  t.bigint  'user_id_to',   null: false, unsigned: true
  t.boolean 'is_blocked',   null: false, default: false
  t.boolean 'is_muted',     null: false, default: false
  t.timestamps
end
add_index       'user_follows', %w[user_id_from user_id_to], name: 'idx_user_follows_on_user_id_from_and_user_id_to', unique: true
add_index       'user_follows', %w[user_id_to],              name: 'idx_user_follows_on_user_id_to'
add_foreign_key 'user_follows', 'users',                     name: 'fk_user_follows_1', column: 'user_id_from'
add_foreign_key 'user_follows', 'users',                     name: 'fk_user_follows_2', column: 'user_id_to'

create_table 'user_profiles', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint  'user_id',          null: false, unsigned: true
  t.string  'name',             null: false, default: '', limit: 25
  t.date    'birth_date'
  t.integer 'housework_career', unsigned: true
  t.string  'image',            null: false, default: ''
  t.string  'description',      limit: 120
  t.string  'website_url',      limit: 100
  t.timestamps
end
add_index       'user_profiles', %w[user_id], name: 'idx_user_profiles_on_user_id'
add_foreign_key 'user_profiles', 'users',     name: 'fk_user_profiles_1'

create_table 'users', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
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
