class Instructor < ApplicationRecord
    belongs_to :user
    has_many :courses, dependent: :delete_all
    validates_presence_of :department
end
