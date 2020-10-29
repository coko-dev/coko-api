# frozen_string_literal: true

create_table 'kitchens', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',          null: false, default: 'My Kitchen'
  t.boolean 'is_subscriber', null: false, default: false
  t.integer 'status_id',     null: false, unsigned: true, default: 1, comment: '{ private: 1, published: 2, official: 3, blacked: 4 }'
  t.bigint  'owner_user_id', null: false, unsigned: true
  t.timestamps
end
add_index       'kitchens', %w[owner_user_id], name: 'idx_kitchens_on_owner_user_id'
add_foreign_key 'kitchens', 'users',           name: 'fk_kitchens_1', column: 'owner_user_id'

create_table 'kitchen_joins', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.integer  'code',       null: false, unsigned: true
  t.bigint   'kitchen_id', null: false, unsigned: true
  t.integer  'status_id',  null: false, default: 1, comment: '{ open: 1, closed: 2 }'
  t.datetime 'close_at',   null: false
  t.timestamps
end
add_index       'kitchen_joins', %w[kitchen_id], name: 'idx_kitchen_joins_on_kitchen_id'
add_foreign_key 'kitchen_joins', 'kitchens',     name: 'fk_kitchen_joins_1'

create_table 'kitchen_ocr_histories', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'kitchen_id', null: false, unsigned: true
  t.json   'log'
  t.timestamps
end
add_index 'kitchen_ocr_histories', %w[kitchen_id], name: 'idx_kitchen_ocr_histories_on_kitchen_id'
add_foreign_key 'kitchen_ocr_histories', 'kitchens', name: 'fk_kitchen_ocr_histories_1'

create_table 'kitchen_products', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint  'kitchen_id',     null: false, unsigned: true
  t.bigint  'product_id',     null: false, unsigned: true
  t.boolean 'is_exists',      null: false, default: false
  t.string  'note'
  t.date    'best_before'
  t.integer 'day_difference', default: 7
  t.timestamps
end
add_index       'kitchen_products', %w[kitchen_id product_id], name: 'idx_kitchen_products_on_kitchen_id_and_product_id'
add_index       'kitchen_products', %w[kitchen_id],            name: 'idx_kitchen_products_on_kitchen_id'
add_index       'kitchen_products', %w[product_id],            name: 'idx_kitchen_products_on_and_product_id'
add_foreign_key 'kitchen_products', 'kitchens',                name: 'fk_kitchen_products_1'
add_foreign_key 'kitchen_products', 'products',                name: 'fk_kitchen_products_2'

create_table 'kitchen_product_histories', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint  'kitchen_id', null: false, unsigned: true
  t.bigint  'product_id', null: false, unsigned: true
  t.bigint  'user_id',    null: false, unsigned: true
  t.integer 'status_id',  null: false, unsigned: true, default: 1, comment: '{ added: 1, updated: 2, deleted: 3 }'
  t.date    'date',       null: false
  t.string  'note'
  t.timestamps
end
add_index       'kitchen_product_histories', %w[kitchen_id product_id user_id], name: 'idx_kitchen_pdt_htr_on_kitchen_id_and_product_id_and_user_id'
add_index       'kitchen_product_histories', %w[kitchen_id],                    name: 'idx_kitchen_product_histories_on_kitchen_id'
add_index       'kitchen_product_histories', %w[product_id],                    name: 'idx_kitchen_product_histories_on_product_id'
add_index       'kitchen_product_histories', %w[user_id],                       name: 'idx_kitchen_product_histories_on_user_id'
add_foreign_key 'kitchen_product_histories', 'kitchens',                        name: 'fk_kitchen_product_histories_1'
add_foreign_key 'kitchen_product_histories', 'products',                        name: 'fk_kitchen_product_histories_2'
add_foreign_key 'kitchen_product_histories', 'users',                           name: 'fk_kitchen_product_histories_3'

create_table 'kitchen_shopping_lists', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'kitchen_id', null: false, unsigned: true
  t.bigint 'product_id', null: false, unsigned: true
  t.bigint 'user_id',    null: false, unsigned: true
  t.string 'note'
  t.timestamps
end
add_index       'kitchen_shopping_lists', %w[kitchen_id product_id user_id], name: 'idx_kitchen_spg_lists_on_kitchen_id_and_product_id_and_user_id'
add_index       'kitchen_shopping_lists', %w[kitchen_id],                    name: 'idx_kitchen_shopping_lists_on_kitchen_id'
add_index       'kitchen_shopping_lists', %w[product_id],                    name: 'idx_kitchen_shopping_lists_on_product_id'
add_index       'kitchen_shopping_lists', %w[user_id],                       name: 'idx_kitchen_shopping_lists_on_user_id'
add_foreign_key 'kitchen_shopping_lists', 'kitchens',                        name: 'fk_kitchen_shopping_lists_1'
add_foreign_key 'kitchen_shopping_lists', 'products',                        name: 'fk_kitchen_shopping_lists_2'
add_foreign_key 'kitchen_shopping_lists', 'users',                           name: 'fk_kitchen_shopping_lists_3'

create_table 'products', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',                null: false
  t.string  'name_hira'
  t.string  'image',               null: false, default: ''
  t.bigint  'product_category_id', null: false, unsigned: true
  t.bigint  'author_id',           null: false, unsigned: true
  t.integer 'status_id',           null: false, unsigned: true, default: 1, comment: '{ published: 1, hidden: 2 }'
  t.timestamps
end
add_index       'products', %w[product_category_id], name: 'idx_products_on_product_category_id'
add_index       'products', %w[author_id],           name: 'idx_products_on_author_id'
add_foreign_key 'products', 'product_categories',    name: 'fk_products_1'
add_foreign_key 'products', 'users',                 name: 'fk_products_2', column: 'author_id'

create_table 'product_categories', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name',                     null: false
  t.string 'name_slug',                null: false
  t.bigint 'product_category_id_from', null: false, default: 0, unsigned: true
  t.timestamps
end
add_index       'product_categories', %w[product_category_id_from], name: 'idx_product_categories_on_product_category_id_from'
add_foreign_key 'product_categories', 'product_categories',         name: 'fk_product_categories_1', column: 'product_category_id_from'

create_table 'product_ocr_strings', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'product_id', null: false, unsigned: true
  t.bigint 'kitchen_id', unsigned: true
  t.string 'ocr_string', null: false
  t.string 'status_id',  null: false, unsigned: true, default: 1, comment: '{ enabled: 1, disabled: 2 }'
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
add_index       'recipes', %w[author_id], name: 'idx_recipes_on_author_id'
add_foreign_key 'recipes', 'users',       name: 'fk_recipes_1', column: 'author_id'

create_table 'recipe_categories', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name',                    null: false
  t.string 'name_slug',               null: false
  t.bigint 'recipe_category_id_from', null: false, default: 0, unsigned: true
  t.timestamps
end
add_index       'recipe_categories', %w[recipe_category_id_from], name: 'idx_recipe_categories_on_recipe_category_id_from'
add_foreign_key 'recipe_categories', 'recipe_categories',         name: 'fk_recipe_categories_1', column: 'recipe_category_id_from'

create_table 'recipe_favorites', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'recipe_id', null: false, unsigned: true
  t.bigint 'user_id',   null: false, unsigned: true
  t.timestamps
end

create_table 'recipe_keywords', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string  'name',       null: false
  t.bigint  'author_id',  null: false, unsigned: true
  t.boolean 'is_blacked', null: false, default: false
  t.timestamps
end
add_index       'recipe_keywords', %w[author_id], name: 'idx_recipe_keywords_on_author_id'
add_foreign_key 'recipe_keywords', 'users',       name: 'fk_recipe_keywords_1', column: 'author_id'

create_table 'recipe_keyword_lists', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'recipe_id',         null: false, unsigned: true
  t.bigint 'recipe_keyword_id', null: false, unsigned: true
  t.timestamps
end
add_index       'recipe_keyword_lists', %w[recipe_id],         name: 'idx_recipe_keyword_lists_on_recipe_id'
add_index       'recipe_keyword_lists', %w[recipe_keyword_id], name: 'idx_recipe_keyword_lists_on_recipe_keyword_id'
add_foreign_key 'recipe_keyword_lists', 'recipes',             name: 'fk_recipe_keyword_lists_1'
add_foreign_key 'recipe_keyword_lists', 'recipe_keywords',     name: 'fk_recipe_keyword_lists_2'

create_table 'recipe_products', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' do |t|
  t.bigint 'recipe_id',  null: false, unsigned: true
  t.bigint 'product_id', null: false, unsigned: true
  t.string 'volume',     null: false, default: ''
  t.string 'note'
  t.timestamps
end
add_index       'recipe_products', %w[recipe_id product_id], name: 'idx_recipe_products_on_recipe_id_and_product_id', unique: true
add_index       'recipe_products', %w[recipe_id],            name: 'idx_recipe_products_on_recipe_id'
add_index       'recipe_products', %w[product_id],           name: 'idx_recipe_products_on_product_id'
add_foreign_key 'recipe_products', 'recipes',                name: 'fk_recipe_products_1'
add_foreign_key 'recipe_products', 'products',               name: 'fk_recipe_products_2'

create_table 'recipe_records', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'author_id', null: false, unsigned: true
  t.bigint 'recipe_id', null: false, unsigned: true
  t.text   'body'
  t.timestamps
end
add_index       'recipe_records', %w[author_id recipe_id], name: 'idx_recipe_records_on_author_id_and_recipe_id', unique: true
add_index       'recipe_records', %w[author_id],           name: 'idx_recipe_records_on_author_id'
add_index       'recipe_records', %w[recipe_id],           name: 'idx_recipe_records_on_recipe_id'
add_foreign_key 'recipe_records', 'users',                 name: 'fk_recipe_records_1', column: 'author_id'
add_foreign_key 'recipe_records', 'recipes',               name: 'fk_recipe_records_2'

create_table 'recipe_record_images', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint 'recipe_record_id', null: false, unsigned: true
  t.string 'image',            null: false, default: ''
  t.timestamps
end
add_index       'recipe_record_images', %w[recipe_record_id], name: 'idx_recipe_record_images_on_recipe_record_id'
add_foreign_key 'recipe_record_images', 'recipe_records',     name: 'fk_recipe_record_images_1'

create_table 'recipe_sections', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.bigint  'recipe_id', null: false, unsigned: true
  t.integer 'status_id', null: false, unsigned: true, default: 1, comment: '{ introduced: 1, advised: 2 }'
  t.text    'body',      null: false
  t.string  'image'
  t.timestamps
end
add_index       'recipe_sections', %w[recipe_id], name: 'idx_recipe_sections_on_recipe_id'
add_foreign_key 'recipe_sections', 'recipes',     name: 'fk_recipe_sections_1'

create_table 'recipe_steps', unsigned: true, force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4' do |t|
  t.bigint  'recipe_id',  null: false, unsigned: true
  t.integer 'sort_order', null: false, unsigned: true
  t.text    'body',       null: false
  t.string  'image'
  t.timestamps
end
add_index       'recipe_steps', %w[recipe_id], name: 'idx_recipe_steps_on_recipe_id'
add_foreign_key 'recipe_steps', 'recipes',     name: 'fk_recipe_steps_1'

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
