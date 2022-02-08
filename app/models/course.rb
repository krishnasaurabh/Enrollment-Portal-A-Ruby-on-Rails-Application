class Course < ApplicationRecord
    belongs_to :instructor
    validates :course_code, presence: true, uniqueness: true 
end
