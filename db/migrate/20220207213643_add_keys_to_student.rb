class AddKeysToStudent < ActiveRecord::Migration[6.1]
  def change
    add_reference :students, :user, null: false, foreign_key: true
  end
end
