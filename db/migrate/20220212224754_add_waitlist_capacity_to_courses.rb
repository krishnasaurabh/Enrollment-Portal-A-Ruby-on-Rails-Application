class AddWaitlistCapacityToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :waitlist_capacity, :integer
  end
end
