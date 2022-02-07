class AddKeysToInstructor < ActiveRecord::Migration[6.1]
  def change
    add_reference :instructors, :user, null: false, foreign_key: true
  end
end
