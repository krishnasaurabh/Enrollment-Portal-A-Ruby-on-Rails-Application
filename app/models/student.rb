class Student < ApplicationRecord
    belongs_to :user
    has_many :enrollments, dependent: :destroy
    has_many :waitlists, dependent: :destroy
    validates_presence_of :date_of_birth
    validates_presence_of :phone_number
    validates_presence_of :major

    validate :check_phone_number

    #check if phone number is valid i.e. should contain only numbers between 0-9 and should not start with a 0
    def check_phone_number
      if !phone_number.match(/^[1-9]{1}[0-9]{9}$/)
          errors.add(:phone_number, "should consist only numbers and should be of length 10 and should not start with 0")
      end
    end
end
