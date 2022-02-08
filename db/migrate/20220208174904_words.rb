class Words < ActiveRecord::Migration[7.0]
  def change
    create_table :words do |t|
      t.string    :word
      t.references  :letter, foreign_key: true
      t.timestamps # add 2 columns, `created_at` and `updated_at`
    end
  end
end
