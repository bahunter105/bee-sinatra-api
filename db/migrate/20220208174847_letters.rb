class Letters < ActiveRecord::Migration[7.0]
  def change
    create_table :letters do |t|
      t.string    :letter
      t.timestamps # add 2 columns, `created_at` and `updated_at`
    end
  end
end
