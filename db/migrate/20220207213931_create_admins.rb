class CreateAdmins < ActiveRecord::Migration[6.1]
  def change
    create_table :admins do |t|
      t.string :phone_number

      t.timestamps
    end
  end
end
