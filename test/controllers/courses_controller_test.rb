require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  def init_user_login(user_fixture)
    get '/users/sign_in'
    sign_in users(user_fixture)
    post user_session_url

    @course = courses(:one)
    @user = users(user_fixture)
  
  end


  # ------------ Index test cases 
  test "should get index for admin" do
    init_user_login(:user_admin)
    get courses_url
    assert_response :success
  end

  test "should get index for student" do
    init_user_login(:user_student1)
    get courses_url
    assert_response :success
  end

  test "should get index for instructor" do
    init_user_login(:user_instructor1)
    get courses_url
    assert_response :success
  end

  # ------------ New course create test cases 
  test "should get new for admin" do
    init_user_login(:user_admin)
    get new_course_url
    assert_response :success
  end  

  test "should get new for instructor" do
    init_user_login(:user_instructor1)
    get new_course_url
    assert_response :success
  end 
  
  test "should not get new for student" do
    init_user_login(:user_student1)
    get new_course_url
    assert_response :redirect
  end  

  # ------------ Create course test cases
  test "should create course if admin" do
    init_user_login(:user_admin)
    assert_difference('Course.count') do
      new_course_details = { capacity: 1, waitlist_capacity: 1, course_code: 'ECE201', description: 'Analog Devices', end_time: '14:30', instructor_id: 1, name: 'AD', room: '2315', start_time: '12:30', status: :open, weekday_one: :MON, weekday_two: :WED}
      post courses_url, params: { course: new_course_details }
    end
    assert_redirected_to course_url(Course.last)
  end

  test "should create course if instructor" do
    init_user_login(:user_instructor1)
    assert_difference('Course.count') do
      new_course_details = { capacity: 1, waitlist_capacity: 1, course_code: 'ECE301', description: 'Digital Devices', end_time: '14:30', instructor_id: 1, name: 'AD', room: '2315', start_time: '12:30', status: :open, weekday_one: :MON, weekday_two: :WED}
      post courses_url, params: { course: new_course_details }
    end
    assert_redirected_to course_url(Course.last)
  end

  test "should not create course if student" do
    init_user_login(:user_student1)
    new_course_details = { capacity: 1, waitlist_capacity: 1, course_code: 'ECE201', description: 'Analog Devices', end_time: '14:30', instructor_id: 1, name: 'AD', room: '2315', start_time: '12:30', status: :open, weekday_one: :MON, weekday_two: :WED}
    post courses_url, params: { course: new_course_details }
    assert_equal(flash[:alert],"Not authorised to perform this action")
    assert_redirected_to courses_url
  end

  #----------Show course
  test "should show course to student" do
    init_user_login(:user_student1)
    get course_url(@course)
    assert_response :success
  end

    #----------Show get edit form
  test "should get edit for admin" do
    init_user_login(:user_admin)
    get edit_course_url(@course)
    assert_response :success
  end

  test "should get edit for instructor" do
    init_user_login(:user_instructor1)
    get edit_course_url(@course)
    assert_response :success
  end

  test "should not get edit for student" do
    init_user_login(:user_student1)
    get edit_course_url(@course)
    assert_response :redirect
  end

  #---------Update course
  test "should update course for admin" do
    init_user_login(:user_admin)
    #FAILING TESTCASE
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_id: @course.instructor_id, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_redirected_to course_url(@course)
  end

  test "should not update course for wrong instructor" do
    init_user_login(:user_instructor2)
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_id: @course.instructor_id, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_equal(flash[:alert],"Not authorised to perform this action")
    assert_redirected_to courses_url
  end

    test "should not update course for student" do
    init_user_login(:user_student1)
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_id: @course.instructor_id, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_equal(flash[:alert],"Not authorised to perform this action")
    assert_redirected_to courses_url
  end  

  test "should destroy course for admin" do
    init_user_login(:user_admin)
    assert_difference('Course.count', -1) do
      delete course_url(@course)
    end
  end

  test "should destroy course for instructor" do
    init_user_login(:user_instructor1)
    assert_difference('Course.count', -1) do
      delete course_url(@course)
    end
  end
  
  test "should not destroy course if other instructor" do
    init_user_login(:user_instructor2)
    assert_response :redirect
  end


  test "should not destroy course if student" do
    init_user_login(:user_student1)
    assert_response :redirect
  end
end
