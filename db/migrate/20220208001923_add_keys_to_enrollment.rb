class AddKeysToEnrollment < ActiveRecord::Migration[6.1]
  def change
    add_reference :enrollments, :student, null: false, foreign_key: true
    add_reference :enrollments, :course, null: false, foreign_key: true
  end
end
