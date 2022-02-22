class Instructor < ApplicationRecord
    belongs_to :user
    has_many :courses, dependent: :destroy
    validates_presence_of :department
end
