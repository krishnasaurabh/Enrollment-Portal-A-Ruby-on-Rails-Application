class CreateStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.date :date_of_birth
      t.string :phone_number
      t.string :major

      t.timestamps
    end
  end
end
