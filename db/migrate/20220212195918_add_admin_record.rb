class AddAdminRecord < ActiveRecord::Migration[6.1]
  def up
    user = User.create!({:name => "SuperUser", :email => "SuperUser@ncsu.edu",:password => "MyStrongPassword1",:user_type => "Admin"})
    admin_user = Admin.create!({:user_id => user.id, :phone_number => "1234567890"})
  end
end
