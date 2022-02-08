class AddKeysToCourse < ActiveRecord::Migration[6.1]
  def change
    add_reference :courses, :instructor, null: false, foreign_key: true
  end
end
