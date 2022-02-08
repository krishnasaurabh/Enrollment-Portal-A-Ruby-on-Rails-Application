class Enrollment < ApplicationRecord
    has_many :students
    has_many :courses
end
