# frozen_string_literal: true

create_table 'admin_users', id: :string, force: :cascade do |t|
  t.string   'email',              null: false
  t.string   'password_digest',    null: false, default: ''
  t.string   'api_token',          null: false, default: ''
  t.integer  'role_id',            null: false, default: 1, comment: '{ read: 1, write: 2, admin: 3 }'
  t.datetime 'last_sign_in_at'
  t.timestamps
end
add_index 'admin_users', %w[email], name: 'idx_admin_users_on_email', unique: true

create_table 'hot_recipe_versions', id: :string, force: :cascade do |t|
  t.string  'version',   null: false
  t.integer 'status_id', null: false, default: 2, comment: '{ enabled: 1, disabled: 2 }'
  t.timestamps
end

create_table 'hot_recipes', id: :string, force: :cascade do |t|
  t.string 'recipe_id',             null: false
  t.string 'hot_recipe_version_id', null: false
  t.timestamps
end
add_index       'hot_recipes', %w[recipe_id hot_recipe_version_id], name: 'idx_hot_recipes_on_recipe_id_and_hot_recipe_version_id'
add_index       'hot_recipes', %w[recipe_id],                       name: 'idx_hot_recipes_on_recipe_id'
add_index       'hot_recipes', %w[hot_recipe_version_id],           name: 'idx_hot_recipes_on_hot_recipe_version_id'
add_foreign_key 'hot_recipes', 'recipes',                           name: 'fk_hot_recipes_1'
add_foreign_key 'hot_recipes', 'hot_recipe_versions',               name: 'fk_hot_recipes_2'

create_table 'hot_recipe_keywords', id: :string, force: :cascade do |t|
  t.string 'recipe_keyword_id', null: false
  t.bigint 'searched_count',    null: false, unsigned: true
  t.bigint 'made_count',        null: false, unsigned: true
  t.date   'version',           null: false
  t.timestamps
end
add_index       'hot_recipe_keywords', %w[recipe_keyword_id version], name: 'idx_hot_recipe_keywords_on_recipe_keyword_id_and_version', unique: true
add_index       'hot_recipe_keywords', %w[recipe_keyword_id],         name: 'idx_hot_recipe_keywords_on_recipe_keyword_id'
add_foreign_key 'hot_recipe_keywords', 'recipe_keywords',             name: 'fk_hot_recipe_keywords_1'

create_table 'hot_users', id: :string, force: :cascade do |t|
  t.string 'user_id',               null: false
  t.bigint 'recipe_favorite_count', null: false, unsigned: true
  t.bigint 'followed_count',        null: false, unsigned: true
  t.date   'version',               null: false
  t.timestamps
end
add_index       'hot_users', %w[user_id version], name: 'idx_hot_users_on_user_id_and_version', unique: true
add_index       'hot_users', %w[user_id],         name: 'idx_hot_users_on_user_id'
add_foreign_key 'hot_users', 'users',             name: 'fk_hot_users_1'

create_table 'kitchens', id: :string, force: :cascade do |t|
  t.string   'name',                   null: false, default: 'My Kitchen'
  t.boolean  'is_subscriber',          null: false, default: false
  t.integer  'status_id',              null: false, unsigned: true, default: 1, comment: '{ is_private: 1, published: 2, official: 3, blacked: 4 }'
  t.datetime 'subscription_expires_at'
  t.string   'owner_user_id'
  t.datetime 'last_action_at'
  t.timestamps
end
add_index       'kitchens', %w[owner_user_id], name: 'idx_kitchens_on_owner_user_id'
add_foreign_key 'kitchens', 'users',           name: 'fk_kitchens_1', column: 'owner_user_id'

create_table 'kitchen_joins', id: :string, force: :cascade do |t|
  t.integer  'code',          null: false, unsigned: true
  t.string   'kitchen_id',    null: false
  t.string   'user_id',       null: false
  t.boolean  'is_confirming', null: false, default: false
  t.integer  'status_id',     null: false, default: 1, comment: '{ open: 1, closed: 2 }'
  t.datetime 'expired_at',    null: false
  t.timestamps
end
add_index       'kitchen_joins', %w[kitchen_id user_id], name: 'idx_kitchen_joins_on_kitchen_id_and_user_id'
add_index       'kitchen_joins', %w[kitchen_id],         name: 'idx_kitchen_joins_on_kitchen_id'
add_index       'kitchen_joins', %w[user_id],            name: 'idx_kitchen_joins_on_user_id'
add_foreign_key 'kitchen_joins', 'kitchens',             name: 'fk_kitchen_joins_1'
add_foreign_key 'kitchen_joins', 'users',                name: 'fk_kitchen_joins_2'

create_table 'kitchen_ocr_histories', id: :string, force: :cascade do |t|
  t.string 'kitchen_id', null: false
  t.string 'log'
  t.timestamps
end
add_index       'kitchen_ocr_histories', %w[kitchen_id], name: 'idx_kitchen_ocr_histories_on_kitchen_id'
add_foreign_key 'kitchen_ocr_histories', 'kitchens',     name: 'fk_kitchen_ocr_histories_1'

create_table 'kitchen_products', id: :string, force: :cascade do |t|
  t.string 'kitchen_id', null: false
  t.string 'product_id', null: false
  t.string 'note'
  t.date   'added_on'
  t.date   'best_before'
  t.timestamps
end
add_index       'kitchen_products', %w[kitchen_id product_id], name: 'idx_kitchen_products_on_kitchen_id_and_product_id'
add_index       'kitchen_products', %w[kitchen_id],            name: 'idx_kitchen_products_on_kitchen_id'
add_index       'kitchen_products', %w[product_id],            name: 'idx_kitchen_products_on_and_product_id'
add_foreign_key 'kitchen_products', 'kitchens',                name: 'fk_kitchen_products_1'
add_foreign_key 'kitchen_products', 'products',                name: 'fk_kitchen_products_2'

create_table 'kitchen_product_histories', id: :string, force: :cascade do |t|
  t.string  'kitchen_id',     null: false
  t.string  'product_id',     null: false
  t.string  'user_id',        null: false
  t.integer 'status_id',      null: false, unsigned: true, default: 1, comment: '{ added: 1, updated: 2, deleted: 3 }'
  t.date    'date',           null: false
  t.integer 'day_difference' # NOTE: Difference in expiration date
  t.string  'note'           # TODO: Not used
  t.timestamps
end
add_index       'kitchen_product_histories', %w[kitchen_id product_id user_id], name: 'idx_kitchen_pdt_htr_on_kitchen_id_and_product_id_and_user_id'
add_index       'kitchen_product_histories', %w[kitchen_id],                    name: 'idx_kitchen_product_histories_on_kitchen_id'
add_index       'kitchen_product_histories', %w[product_id],                    name: 'idx_kitchen_product_histories_on_product_id'
add_index       'kitchen_product_histories', %w[user_id],                       name: 'idx_kitchen_product_histories_on_user_id'
add_foreign_key 'kitchen_product_histories', 'kitchens',                        name: 'fk_kitchen_product_histories_1'
add_foreign_key 'kitchen_product_histories', 'products',                        name: 'fk_kitchen_product_histories_2'
add_foreign_key 'kitchen_product_histories', 'users',                           name: 'fk_kitchen_product_histories_3'

create_table 'kitchen_shopping_lists', id: :string, force: :cascade do |t|
  t.string 'kitchen_id', null: false
  t.string 'product_id', null: false
  t.string 'user_id',    null: false
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

create_table 'products', id: :string, force: :cascade do |t|
  t.string  'name_hira'
  t.string  'name',                null: false
  t.string  'image',               null: false, default: '', limit: 2_048
  t.string  'product_category_id', null: false
  t.string  'author_id',           null: false
  t.integer 'status_id',           null: false, unsigned: true, default: 1, comment: '{ published: 1, hidden: 2 }'
  t.timestamps
end
add_index       'products', %w[product_category_id], name: 'idx_products_on_product_category_id'
add_index       'products', %w[author_id],           name: 'idx_products_on_author_id'
add_foreign_key 'products', 'product_categories',    name: 'fk_products_1'
add_foreign_key 'products', 'admin_users',           name: 'fk_products_2', column: 'author_id'

create_table 'product_categories', id: :string, force: :cascade do |t|
  t.string  'name',                     null: false
  t.string  'name_slug',                null: false
  t.integer 'position',                 null: false, unsigned: true
  t.string  'product_category_id_from'
  t.string  'color_code'
  t.timestamps
end
add_index       'product_categories', %w[product_category_id_from], name: 'idx_product_categories_on_product_category_id_from'
add_foreign_key 'product_categories', 'product_categories',         name: 'fk_product_categories_1', column: 'product_category_id_from'

create_table 'product_ocr_strings', id: :string, force: :cascade do |t|
  t.string  'product_id', null: false
  t.string  'kitchen_id'
  t.string  'ocr_string', null: false
  t.integer 'status_id',  null: false, unsigned: true, default: 1, comment: '{ enabled: 1, disabled: 2 }'
  t.timestamps
end
add_index       'product_ocr_strings', %w[product_id kitchen_id], name: 'idx_product_ocr_strings_on_product_id_and_kitchen_id'
add_index       'product_ocr_strings', %w[product_id],            name: 'idx_product_ocr_strings_on_product_id'
add_index       'product_ocr_strings', %w[kitchen_id],            name: 'idx_product_ocr_strings_on_kitchen_id'
add_foreign_key 'product_ocr_strings', 'products',                name: 'fk_product_ocr_strings_1'
add_foreign_key 'product_ocr_strings', 'kitchens',                name: 'fk_product_ocr_strings_2'

create_table 'product_requests', id: :string, force: :cascade do |t|
  t.string  'user_id',            null: false
  t.string  'name',               null: false
  t.text    'body'
  t.integer 'status_id',          null: false, unsigned: true, default: 1, comment: '{ pending: 1, done: 2 }'
  t.boolean 'is_required_notice', null: false, default: false
  t.timestamps
end
add_index       'product_requests', %w[user_id], name: 'idx_product_requests_on_user_id'
add_foreign_key 'product_requests', 'users',     name: 'fk_product_requests_1'

create_table 'recipes', id: :string, force: :cascade do |t|
  t.string  'name',               null: false
  t.string  'author_id',          null: false
  t.integer 'status_id',          null: false, unsigned: true, default: 1, comment: '{ published: 1, hidden: 2 }'
  t.string  'image',              null: false, default: '', limit: 2_048
  t.string  'recipe_category_id', null: false
  t.integer 'cooking_time',       null: false, unsigned: true, default: 30
  t.integer 'servings',           null: false, unsigned: true, default: 4
  t.string  'favorite_count',     null: false, unsigned: true, default: 0
  t.timestamps
end
add_index       'recipes', %w[author_id],          name: 'idx_recipes_on_author_id'
add_index       'recipes', %w[recipe_category_id], name: 'idx_recipes_on_recipe_category_id'
add_foreign_key 'recipes', 'users',                name: 'fk_recipes_1', column: 'author_id'
add_foreign_key 'recipes', 'recipe_categories',    name: 'fk_recipes_2'

create_table 'recipe_categories', id: :string, force: :cascade do |t|
  t.string 'name',                    null: false
  t.string 'name_slug',               null: false
  t.string 'recipe_category_id_from'
  t.string 'color_code'
  t.timestamps
end
add_index       'recipe_categories', %w[recipe_category_id_from], name: 'idx_recipe_categories_on_recipe_category_id_from'
add_foreign_key 'recipe_categories', 'recipe_categories',         name: 'fk_recipe_categories_1', column: 'recipe_category_id_from'

create_table 'recipe_favorites', id: :string, force: :cascade do |t|
  t.string 'recipe_id', null: false
  t.string 'user_id',   null: false
  t.timestamps
end
add_index       'recipe_favorites', %w[recipe_id user_id], name: 'idx_recipe_favorites_on_recipe_id_and_user_id'
add_index       'recipe_favorites', %w[recipe_id],         name: 'idx_recipe_favorites_on_recipe_id'
add_index       'recipe_favorites', %w[user_id],           name: 'idx_recipe_favorites_on_user_id'
add_foreign_key 'recipe_favorites', 'recipes',             name: 'fk_recipe_favorites_1'
add_foreign_key 'recipe_favorites', 'users',               name: 'fk_recipe_favorites_2'

create_table 'recipe_keywords', id: :string, force: :cascade do |t|
  t.string  'name',       null: false
  t.string  'name_hira',  null: false
  t.string  'author_id',  null: false
  t.boolean 'is_blacked', null: false, default: false
  t.timestamps
end
add_index       'recipe_keywords', %w[author_id], name: 'idx_recipe_keywords_on_author_id'
add_foreign_key 'recipe_keywords', 'admin_users', name: 'fk_recipe_keywords_1', column: 'author_id'

create_table 'recipe_keyword_lists', id: :string, force: :cascade do |t|
  t.string 'recipe_id',         null: false
  t.string 'recipe_keyword_id', null: false
  t.timestamps
end
add_index       'recipe_keyword_lists', %w[recipe_id],         name: 'idx_recipe_keyword_lists_on_recipe_id'
add_index       'recipe_keyword_lists', %w[recipe_keyword_id], name: 'idx_recipe_keyword_lists_on_recipe_keyword_id'
add_foreign_key 'recipe_keyword_lists', 'recipes',             name: 'fk_recipe_keyword_lists_1'
add_foreign_key 'recipe_keyword_lists', 'recipe_keywords',     name: 'fk_recipe_keyword_lists_2'

create_table 'recipe_products', id: :string, force: :cascade do |t|
  t.string 'recipe_id',  null: false
  t.string 'product_id', null: false
  t.string 'volume',     null: false, default: ''
  t.string 'note'
  t.timestamps
end
add_index       'recipe_products', %w[recipe_id product_id], name: 'idx_recipe_products_on_recipe_id_and_product_id'
add_index       'recipe_products', %w[recipe_id],            name: 'idx_recipe_products_on_recipe_id'
add_index       'recipe_products', %w[product_id],           name: 'idx_recipe_products_on_product_id'
add_foreign_key 'recipe_products', 'recipes',                name: 'fk_recipe_products_1'
add_foreign_key 'recipe_products', 'products',               name: 'fk_recipe_products_2'

create_table 'recipe_records', id: :string, force: :cascade do |t|
  t.string 'author_id', null: false
  t.string 'recipe_id', null: false
  t.text   'body'
  t.timestamps
end
add_index       'recipe_records', %w[author_id recipe_id], name: 'idx_recipe_records_on_author_id_and_recipe_id'
add_index       'recipe_records', %w[author_id],           name: 'idx_recipe_records_on_author_id'
add_index       'recipe_records', %w[recipe_id],           name: 'idx_recipe_records_on_recipe_id'
add_foreign_key 'recipe_records', 'users',                 name: 'fk_recipe_records_1', column: 'author_id'
add_foreign_key 'recipe_records', 'recipes',               name: 'fk_recipe_records_2'

create_table 'recipe_record_images', id: :string, force: :cascade do |t|
  t.string 'recipe_record_id', null: false
  t.string 'image',            null: false, default: ''
  t.timestamps
end
add_index       'recipe_record_images', %w[recipe_record_id], name: 'idx_recipe_record_images_on_recipe_record_id'
add_foreign_key 'recipe_record_images', 'recipe_records',     name: 'fk_recipe_record_images_1'

create_table 'recipe_sections', id: :string, force: :cascade do |t|
  t.string  'recipe_id', null: false
  t.integer 'status_id', null: false, default: 1, comment: '{ introduced: 1, adviced: 2 }'
  t.text    'body',      null: false
  t.timestamps
end
add_index       'recipe_sections', %w[recipe_id], name: 'idx_recipe_sections_on_recipe_id'
add_foreign_key 'recipe_sections', 'recipes',     name: 'fk_recipe_sections_1'

create_table 'recipe_steps', id: :string, force: :cascade do |t|
  t.string  'recipe_id',  null: false
  t.integer 'sort_order', null: false
  t.text    'body',       null: false
  t.string  'image'
  t.timestamps
end
add_index       'recipe_steps', %w[recipe_id], name: 'idx_recipe_steps_on_recipe_id'
add_foreign_key 'recipe_steps', 'recipes',     name: 'fk_recipe_steps_1'

create_table 'service_requests', id: :string, force: :cascade do |t|
  t.string  'user_id',            null: false
  t.text    'body',               null: false
  t.integer 'type_id',            null: false, unsigned: true, default: 1, comment: '{ request: 1, report: 2, other: 3 }'
  t.integer 'status_id',          null: false, unsigned: true, default: 1, comment: '{ pending: 1, done: 2 }'
  t.boolean 'is_required_notice', null: false, default: false
  t.timestamps
end
add_index       'service_requests', %w[user_id], name: 'idx_service_requests_on_user_id'
add_foreign_key 'service_requests', 'users',     name: 'fk_service_requests_1'

create_table 'user_follows', id: :string, force: :cascade do |t|
  t.string  'user_id_from', null: false
  t.string  'user_id_to',   null: false
  t.integer 'status_id',    null: false, default: 1, comment: '{ followed: 1, blocked: 2, muted: 3 }'
  t.timestamps
end
add_index       'user_follows', %w[user_id_from user_id_to status_id], name: 'idx_user_follows_on_user_id_from_and_user_id_to_and_status_id', unique: true
add_index       'user_follows', %w[user_id_to],                        name: 'idx_user_follows_on_user_id_to'
add_foreign_key 'user_follows', 'users',                               name: 'fk_user_follows_1', column: 'user_id_from'
add_foreign_key 'user_follows', 'users',                               name: 'fk_user_follows_2', column: 'user_id_to'

create_table 'user_profiles', id: :string, force: :cascade do |t|
  t.string  'user_id',          null: false
  t.string  'display_id',       null: false, default: '', limit: 16
  t.string  'name',             null: false, default: '', limit: 25
  t.date    'birth_date'
  t.integer 'housework_career', unsigned: true
  t.string  'image',            null: false, default: '', limit: 2_048
  t.string  'description',      limit: 120
  t.string  'website_url',      limit: 100
  t.timestamps
end
add_index       'user_profiles', %w[user_id], name: 'idx_user_profiles_on_user_id'
add_foreign_key 'user_profiles', 'users',     name: 'fk_user_profiles_1'

create_table 'users', id: :string, force: :cascade do |t|
  t.string   'code',                   null: false, default: ''
  t.string   'api_token',              null: false, default: ''
  t.string   'firebase_id_token',      null: false, default: ''
  t.string   'firebase_refresh_token', null: false, default: ''
  t.string   'kitchen_id'
  t.string   'email'
  t.integer  'status_id',              null: false, unsigned: true, default: 1, comment: '{ is_private: 1, published: 2, official: 3 }'
  t.boolean  'is_allowed',             null: false, default: true
  t.string   'password_digest',        null: false, default: ''
  t.integer  'following_count',        null: false, unsigned: true, default: 0
  t.integer  'follower_count',         null: false, unsigned: true, default: 0
  t.datetime 'last_sign_in_at'
  t.timestamps
end
add_index 'users', %w[code],  name: 'idx_users_on_code',  unique: true
add_index 'users', %w[email], name: 'idx_users_on_email', unique: true

create_table 'violation_reports', id: :string, force: :cascade do |t|
  t.string 'reporting_user_id', null: false
  t.string 'reported_user_id',  null: false
  t.string 'reason',            limit: 120
  t.string 'description',       limit: 120
  t.timestamps
end
add_index       'violation_reports', %w[reporting_user_id reported_user_id], name: 'idx_violation_reports_on_reporting_user_id_and_reported_user_id'
add_index       'violation_reports', %w[reporting_user_id],                  name: 'idx_violation_reports_on_reporting_user_id'
add_index       'violation_reports', %w[reported_user_id],                   name: 'idx_violation_reports_on_reported_user_id'
add_foreign_key 'violation_reports', 'users',                                name: 'fk_violation_reports_2', column: 'reporting_user_id'
add_foreign_key 'violation_reports', 'users',                                name: 'fk_violation_reports_1', column: 'reported_user_id'

create_table 'active_storage_blobs', force: :cascade do |t|
  t.string   :key,          null: false
  t.string   :filename,     null: false
  t.string   :content_type
  t.text     :metadata
  t.string   :service_name, null: false
  t.bigint   :byte_size,    null: false
  t.string   :checksum,     null: false
  t.datetime :created_at,   null: false
end
add_index 'active_storage_blobs', %w[key], name: 'idx_active_storage_blobs_on_key', unique: true

create_table 'active_storage_attachments', force: :cascade do |t|
  t.string     :name,     null: false
  t.references :record,   null: false, polymorphic: true, index: false
  t.references :blob,     null: false
  t.datetime   :created_at, null: false
end
add_index       'active_storage_attachments', %w[record_type record_id blob_id], name: 'index_active_storage_attachments_uniqueness', unique: true
add_foreign_key 'active_storage_attachments', 'active_storage_blobs',            name: 'fk_active_storage_attachments_1', column: 'blob_id'

create_table 'active_storage_variant_records', force: :cascade do |t|
  t.belongs_to :blob, null: false, index: false
  t.string     :variation_digest, null: false
end
add_index       'active_storage_variant_records', %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
add_foreign_key 'active_storage_variant_records', 'active_storage_blobs',       name: 'fk_active_storage_variant_records_1', column: 'blob_id'
