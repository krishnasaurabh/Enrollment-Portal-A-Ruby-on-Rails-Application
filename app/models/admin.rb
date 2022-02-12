class Admin < ApplicationRecord
    belongs_to :user
    validates_presence_of :phone_number
end
