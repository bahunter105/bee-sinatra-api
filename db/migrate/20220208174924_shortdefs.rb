class Shortdefs < ActiveRecord::Migration[7.0]
  def change
    create_table :shortdefs do |t|
      t.string    :shortdef
      t.references  :word, foreign_key: true
      t.timestamps # add 2 columns, `created_at` and `updated_at`
    end
  end
end
