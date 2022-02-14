class AddShortdefToWords < ActiveRecord::Migration[7.0]
  def change
    add_column :words, :shortdef, :string, array: true
  end
end
