require 'rails_helper'
require 'spec_helper'
require 'shoulda/matchers'


describe "attribute validations" do
  subject { Course.new(id: 3, 
  name: "DADA", 
  description: "Defense Against", weekday_one: "WED", weekday_two: "THU", 
  start_time: "03:30", end_time: "06:30", course_code: "WIZ606", 
  capacity: 1, status: :closed, room: "online", instructor_id: 2, waitlist_capacity: 1) }
  
  it "should do validations for all attributes" do
    expect(subject).to be_valid
  end    
end

describe "attribute failed validations" do #Status has been set to null, the validation should fail
  subject { Course.new(id: 4, 
  name: "DADA", 
  description: "Defense Against", weekday_one: "WED", weekday_two: "THU", 
  start_time: "03:30", end_time: "06:30", course_code: "WIZ606", 
  capacity: 1, status: nil, room: "online", instructor_id: 2, waitlist_capacity: 1) }
  
  it "should do validations for all attributes" do
    expect(subject).not_to be_valid
  end    
end

RSpec.describe 'take only valid weekdays', type: :model do
  subject { Course.new(id: 5, 
  name: "Potions", 
  description: "Potions III", weekday_one: :WED, weekday_two: :THU, 
  start_time: "03:30", end_time: "06:30", course_code: "WIZ330", 
  capacity: 1, status: :waitlist, room: "online", instructor_id: 1, waitlist_capacity: 1) }

  it { is_expected.to allow_values(:MON, :TUE, :WED, :THU).for(:weekday_one) }
end
  
RSpec.describe Course, type: :model do 
  it { is_expected.to belong_to(:instructor) }
end