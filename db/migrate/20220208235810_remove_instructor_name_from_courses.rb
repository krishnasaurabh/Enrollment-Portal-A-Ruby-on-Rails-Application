class RemoveInstructorNameFromCourses < ActiveRecord::Migration[6.1]
  def change
    remove_column :courses, :instructor_name, :string
  end
end
