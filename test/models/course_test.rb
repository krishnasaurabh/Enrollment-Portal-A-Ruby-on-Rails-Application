require "test_helper"
require 'rspec/autorun'


class CourseTest < ActiveSupport::TestCase

  #For a new course, check that all its attributes are validated
  RSpec.describe "attribute validations" do
    subject { Course.new(id: 3, 
    name: "DADA", 
    description: "Defense Against", weekday_one: "WED", weekday_two: "THU", 
    start_time: "03:30", end_time: "06:30", course_code: "WIZ606", 
    capacity: 1, status: :closed, room: "online", instructor_id: 2, waitlist_capacity: 1) }
    
    it "should do validations for all attributes" do
      expect(subject).to be_valid
    end    
  end

  #For a new course with violating attribute values, test that the code is able to identify it as invalid value.
  RSpec.describe "attribute failed validations" do #Status has been set to null, the validation should fail
    subject { Course.new(id: 4, 
    name: "DADA", 
    description: "Defense Against", weekday_one: "WED", weekday_two: "THU", 
    start_time: "03:30", end_time: "06:30", course_code: "WIZ606", 
    capacity: 1, status: nil, room: "online", instructor_id: 2, waitlist_capacity: 1) }
    
    it "should do validations for all attributes" do
      expect(subject).not_to be_valid
    end    
  end


end
