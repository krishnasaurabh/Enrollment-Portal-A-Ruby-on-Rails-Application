require "application_system_test_case"

class CoursesTest < ApplicationSystemTestCase
  setup do
    @course = courses(:one)
  end

  test "visiting the index" do
    visit courses_url
    assert_selector "h1", text: "Courses"
  end

  test "creating a Course" do
    visit courses_url
    click_on "New Course"

    fill_in "Capacity", with: @course.capacity
    fill_in "Course code", with: @course.course_code
    fill_in "Description", with: @course.description
    fill_in "End time", with: @course.end_time
    fill_in "Instructor", with: @course.instructor_id
    fill_in "Instructor name", with: @course.instructor_name
    fill_in "Name", with: @course.name
    fill_in "Room", with: @course.room
    fill_in "Start time", with: @course.start_time
    fill_in "Status", with: @course.status
    fill_in "Weekday one", with: @course.weekday_one
    fill_in "Weekday two", with: @course.weekday_two
    click_on "Create Course"

    assert_text "Course was successfully created"
    click_on "Back"
  end

  test "updating a Course" do
    visit courses_url
    click_on "Edit", match: :first

    fill_in "Capacity", with: @course.capacity
    fill_in "Course code", with: @course.course_code
    fill_in "Description", with: @course.description
    fill_in "End time", with: @course.end_time
    fill_in "Instructor", with: @course.instructor_id
    fill_in "Instructor name", with: @course.instructor_name
    fill_in "Name", with: @course.name
    fill_in "Room", with: @course.room
    fill_in "Start time", with: @course.start_time
    fill_in "Status", with: @course.status
    fill_in "Weekday one", with: @course.weekday_one
    fill_in "Weekday two", with: @course.weekday_two
    click_on "Update Course"

    assert_text "Course was successfully updated"
    click_on "Back"
  end

  test "destroying a Course" do
    visit courses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Course was successfully destroyed"
  end
end
