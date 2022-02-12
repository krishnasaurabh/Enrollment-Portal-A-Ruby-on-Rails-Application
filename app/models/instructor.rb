class Instructor < ApplicationRecord
    belongs_to :user
    has_many :courses
    validates_presence_of :department
end
