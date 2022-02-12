class Student < ApplicationRecord
    belongs_to :user
    has_many :enrollments
    validates_presence_of :date_of_birth
    validates_presence_of :phone_number
    validates_presence_of :major
end
