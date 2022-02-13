class Waitlist < ApplicationRecord
  belongs_to :student
  belongs_to :course
  validates :student_id, :uniqueness => {:scope => :course_id, :message => "You have already waitlisted for this course."}
end
