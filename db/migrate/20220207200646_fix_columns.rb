class FixColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :type, :user_type, :string
  end
end
