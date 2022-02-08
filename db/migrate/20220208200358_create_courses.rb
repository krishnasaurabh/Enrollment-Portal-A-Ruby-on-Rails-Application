class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :description
      t.string :instructor_name
      t.integer :weekday_one
      t.integer :weekday_two
      t.string :start_time
      t.string :end_time
      t.string :course_code
      t.integer :capacity
      t.integer :status
      t.string :room
      t.references :instructor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
