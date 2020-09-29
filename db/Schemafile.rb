# frozen_string_literal: true

create_table 'recipe_categories', force: :cascade, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
  t.string 'name'
  t.string 'name_slug'
  t.bigint 'recipe_category_id'
  t.timestamps
end
