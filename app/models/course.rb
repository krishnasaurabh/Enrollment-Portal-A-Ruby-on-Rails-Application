class Course < ApplicationRecord
    include ActiveModel::Dirty
    validate :capacity_change, :if => :capacity_changed? || :waitlist_capacity_changed?

    belongs_to :instructor
    has_many :enrollments, dependent: :destroy
    has_many :waitlists, dependent: :destroy
    validates :course_code, presence: true, uniqueness: true 
    validates :status, presence: true
    validates :name, presence: true
    validates :description, presence: true
    validates :weekday_one, presence: true
    validates :capacity, :numericality => {greater_than: 0}
    validates :waitlist_capacity, :numericality => {greater_than_or_equal_to: 0}
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :room, presence: true
    validate :validate_week_one_two
    validate :start_end_time_check
    validate :check_course_code
    enum weekday_one: [:MON, :TUE, :WED, :THU, :FRI], _prefix: true
    enum weekday_two: [:MON, :TUE, :WED, :THU, :FRI], _prefix: true
    enum status: [:open, :closed, :waitlist], _prefix: true


    #If one tries to reduce the course capacity, throw an error. Similarly, if one tries to reduce waitlist capacity, throw error
    def capacity_change
        if capacity_was && capacity < capacity_was
            errors.add(:capacity, "Can only be increased") 
        elsif waitlist_capacity_was && waitlist_capacity < waitlist_capacity_was
            errors.add(:waitlist_capacity,  "Can only be increased")
        end
    end

    #CHecking that the two weekdays are not same. 
    def validate_week_one_two
        if weekday_two.present? && weekday_one == weekday_two
            errors.add(:weekday_two, "Weekday One and Weekday Two cannot be the same.")
        end
    end

    #Checking that the start and end times follow stipulated HH:MM format
    def start_end_time_check
        if m = start_time.match(/^([0-1]?[0-9]|2[0-3]):([0-5][0-9])/)
            hh,mm = m.captures.map{|s| s.to_i}
        else
            errors.add(:start_time, "should be in HH:MM format")
            return
        end

        if m = end_time.match(/^([0-1]?[0-9]|2[0-3]):([0-5][0-9])/)
            endhh,endmm = m.captures.map{|s| s.to_i}
        else
            errors.add(:end_time, "should be in HH:MM format")
            return
        end
        
        if endhh<hh || (endhh==hh && endmm<=mm) 
            errors.add(:end_time, "should be after the start time")
        end
    end

    #Checking that course code has 3 lettres followed by 3 numbers. Throw error otherwise. 
    def check_course_code
        if !course_code.match(/^[A-Z]{3}[0-9]{3}$/)
            errors.add(:course_code, "should have the format 3 letters followed by 3 digits, e.g. ECE123, CSA090")
        end
    end
end
