class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include ActiveModel::Dirty
  validate :user_type_change, :if => :user_type_changed?
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence: true, uniqueness: true
  validates :user_type, presence: true
  validates :name, presence: true
  has_one :instructors
  has_one :students


  
  def user_type_change
    if user_type_was != user_type 
        errors.add(:user_type, "cannot be changed") 
    end
end
end
