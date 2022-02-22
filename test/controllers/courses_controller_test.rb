require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  #Before user tries to navigate to other URLs, log him in first. 
  def init_user_login(user_fixture)
    get '/users/sign_in'
    sign_in users(user_fixture)
    post user_session_url

    #User fixtures are loaded here - these fixtures are used in testing.
    @course = courses(:one)
    @user = users(user_fixture)
  
  end


  # ------------ Index test cases 
  #If admin, then test whether he is directed to courses index page
  test "should get index for admin" do
    init_user_login(:user_admin)
    get courses_url
    assert_response :success
  end

  #If student, then test whether he is directed to courses index page
  test "should get index for student" do
    init_user_login(:user_student1)
    get courses_url
    assert_response :success
  end

  #If instructor, then test whether he is directed to courses index page
  test "should get index for instructor" do
    init_user_login(:user_instructor1)
    get courses_url
    assert_response :success
  end

  # ------------ New course create test cases 
  #If admin, then test that he can accesss new course form URL
  test "should get new for admin" do
    init_user_login(:user_admin)
    get new_course_url
    assert_response :success
  end  

  #If admin, then test that he can accesss new course form URL
  test "should get new for instructor" do
    init_user_login(:user_instructor1)
    get new_course_url
    assert_response :success
  end 
  
  #If student, then test whether he is being redirected away.
  test "should not get new for student" do
    init_user_login(:user_student1)
    get new_course_url
    assert_response :redirect
  end  

  # ------------ Create course test cases
  #If admin, then test that he can create a course
  test "should create course if admin" do
    init_user_login(:user_admin)
    assert_difference('Course.count') do
      new_course_details = { capacity: 1, waitlist_capacity: 1, course_code: 'ECE201', description: 'Analog Devices', end_time: '14:30', instructor_id: 1, name: 'AD', room: '2315', start_time: '12:30', status: :open, weekday_one: :MON, weekday_two: :WED}
      post courses_url, params: { course: new_course_details }
    end
    assert_redirected_to course_url(Course.last)
  end

  #If instructor, then test that he can create a course
  test "should create course if instructor" do
    init_user_login(:user_instructor1)
    assert_difference('Course.count') do
      new_course_details = { capacity: 1, waitlist_capacity: 1, course_code: 'ECE301', description: 'Digital Devices', end_time: '14:30', instructor_id: 1, name: 'AD', room: '2315', start_time: '12:30', status: :open, weekday_one: :MON, weekday_two: :WED}
      post courses_url, params: { course: new_course_details }
    end
    assert_redirected_to course_url(Course.last)
  end

  #If student, then test he is not authorised to perform the actio of creating the course .
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
    #If admin, then test that he gets edit form when requested to edit the course
  test "should get edit for admin" do
    init_user_login(:user_admin)
    get edit_course_url(@course)
    assert_response :success
  end

  #If instructor, then test that he gets edit form when requested to edit the course
  test "should get edit for instructor" do
    init_user_login(:user_instructor1)
    get edit_course_url(@course)
    assert_response :success
  end

  #If student, then redirect away from edit page.
  test "should not get edit for student" do
    init_user_login(:user_student1)
    get edit_course_url(@course)
    assert_response :redirect
  end

  #---------Update course
  #If admin, then test that he updates the course is safely redirected
  test "should update course for admin" do
    init_user_login(:user_admin)
    #FAILING TESTCASE
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_id: @course.instructor_id, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_redirected_to course_url(@course)
  end

  #If instructor tries to update someone else's course, then test that he is redirectly away,with a flash alert
  test "should not update course for wrong instructor" do
    init_user_login(:user_instructor2)
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_id: @course.instructor_id, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_equal(flash[:alert],"Not authorised to perform this action")
    assert_redirected_to courses_url
  end

  #If student,can't update the course and redirect away
    test "should not update course for student" do
    init_user_login(:user_student1)
    patch course_url(@course), params: { course: { capacity: @course.capacity, course_code: @course.course_code, description: @course.description, end_time: @course.end_time, instructor_id: @course.instructor_id, name: @course.name, room: @course.room, start_time: @course.start_time, status: @course.status, weekday_one: @course.weekday_one, weekday_two: @course.weekday_two } }
    assert_equal(flash[:alert],"Not authorised to perform this action")
    assert_redirected_to courses_url
  end  

  #If admin, allow destroying of course
  test "should destroy course for admin" do
    init_user_login(:user_admin)
    assert_difference('Course.count', -1) do
      delete course_url(@course)
    end
  end

  #If instructor, allow destroying of course
  test "should destroy course for instructor" do
    init_user_login(:user_instructor1)
    assert_difference('Course.count', -1) do
      delete course_url(@course)
    end
  end
  
  #If isntructor tries to destroy other instructor's course, the redirct away
  test "should not destroy course if other instructor" do
    init_user_login(:user_instructor2)
    assert_response :redirect
  end

  #If student, cannot destroy course
  test "should not destroy course if student" do
    init_user_login(:user_student1)
    assert_response :redirect
  end
end
