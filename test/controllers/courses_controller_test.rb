require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
  end

  test "should get index" do
    get courses_url
    assert_response :success
  end

  test "should get new" do
    get new_course_url
    assert_response :success
  end

  test "should create course" do
    assert_difference('Course.count') do
      post courses_url, params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_name: @course.instructor_name, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    end

    assert_redirected_to course_url(Course.last)
  end

  test "should show course" do
    get course_url(@course)
    assert_response :success
  end

  test "should get edit" do
    get edit_course_url(@course)
    assert_response :success
  end

  test "should update course" do
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_name: @course.instructor_name, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_redirected_to course_url(@course)
  end

  test "should destroy course" do
    assert_difference('Course.count', -1) do
      delete course_url(@course)
    end

    assert_redirected_to courses_url
  end
end
