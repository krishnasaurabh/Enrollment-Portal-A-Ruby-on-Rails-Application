class HomeController < ApplicationController
  #index page
  def index
    #check if the current logged in user is an instructor or not
    if is_instructor?
      if !Instructor.exists?(user_id:current_user.id)
        inst = Instructor.new
        inst.user_id = current_user.id
        inst.department = 'edit deptartment'
        inst.save!
        p inst
        redirect_to edit_instructor_path :id=>inst.id
      end
    end

    #check if the current logged in user is a student or not
    if is_student?
      if !Student.exists?(user_id:current_user.id)
        stud = Student.new
        stud.user_id = current_user.id
        stud.phone_number = 'Edit Phone'
        stud.date_of_birth = Date.current
        stud.major = 'Edit Major'
        stud.save!
        p stud
        redirect_to edit_student_path :id=>stud.id
      end
    end


  end

  # GET /about_us
  # shows the fancy about page
  def about_us
  end


end
