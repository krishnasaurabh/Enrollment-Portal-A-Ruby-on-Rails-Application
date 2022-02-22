require "test_helper"

class UserTest < ActiveSupport::TestCase
  test 'should not be able to update to empty name' do
    users(:user_instructor1).name = ''
    assert_not users(:user_instructor1).save
  end

  test 'should be able to update name' do
    users(:user_instructor1).name = 'prasanna'
    assert users(:user_instructor1).save
  end


  test 'should not be able to update to empty email' do
    users(:user_instructor1).email = ''
    assert_not users(:user_instructor1).save
  end

  test 'should able to update email' do
    users(:user_student2).email = 'atharva@email.edu'
    assert users(:user_student2).save
  end

  test 'should not be able to update to empty password' do
    users(:user_instructor1).password = ''
    assert_not users(:user_instructor1).save
  end

  test 'should be able to update password' do
    users(:user_student2).email = 'atharva@email.edu'
    assert users(:user_student2).save
  end

  test 'should not be able to update password less than 6' do
    users(:user_instructor1).password = '1234'
    assert_not users(:user_instructor1).save
  end

  test 'should be able to update password greater than 6 characters' do
    users(:user_student2).password = 'atharva123'
    assert users(:user_student2).save
  end


"""
  test 'duplicate email' do
    user = User.new
    user.email = 'abcd@gmail.com'
    user.password_digest = BCrypt::Password.create('secret')
    user.name = 'Rachit'
    assert_not user.save
  end

  test 'destroy user' do
    assert users(:one).delete
  end

  test 'empty field user' do
    user = User.new
    user.email = ' '
    user.password_digest = BCrypt::Password.create('secret')
    user.name = ' '
    assert_not user.save
  end

  test 'invalid email' do
    user = User.new
    user.email = 'abcdgmailcom'
    user.password_digest = BCrypt::Password.create('secret')
    user.name = 'Rachit'
    assert_not user.save
  end

"""
end