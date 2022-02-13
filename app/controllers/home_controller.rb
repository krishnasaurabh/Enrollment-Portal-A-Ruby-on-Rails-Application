class HomeController < ApplicationController
  def index
    if is_instructor?
      if !Instructor.exists?(user_id:current_user.id)
        print "I am inside Inst"
        inst = Instructor.new
        inst.user_id = current_user.id
        inst.department = ''
        inst.save
        p inst
        redirect_to edit_instructor_path :id=>inst.id
      end
    end

    if is_student?
      if !Student.exists?(user_id:current_user.id)
        print "I am inside Student"
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



end
