class ApplicationController < ActionController::Base
     before_action :configure_permitted_parameters , if: :devise_controller?
     before_action :authenticate_user!, unless: :devise_controller?
     before_action :check_student_instructor_registered, unless: :devise_controller?

     #check if logged in user is a student
     def is_student?
          user_signed_in? && current_user.user_type == "Student"
     end
     helper_method :is_student?

     #check if logged in user is a instructor
     def is_instructor?
          user_signed_in? && current_user.user_type == "Instructor"
     end
     helper_method :is_instructor?

     #check if logged in user is a admin
     def is_admin?
          user_signed_in? && current_user.user_type == "Admin"
     end
     helper_method :is_admin?

     #check if the student and instructor are registered or not
     def check_student_instructor_registered

          #check if instructor
          if is_instructor?
               if !Instructor.exists?(user_id:current_user.id)
                    redirect_to new_instructor_path
               end
          end

          #check if student
          if is_student?
               if !Student.exists?(user_id:current_user.id)
                    redirect_to new_student_path
               end
          end
     end

     #get the current student details from the database
     def get_cur_student
          if is_student?
               return Student.find_by(user_id: current_user.id)
          end
          return nil
     end
     helper_method :get_cur_student

     # get the current instructor details from the database
     def get_cur_instructor
          if is_instructor?
               return Instructor.find_by(user_id: current_user.id)
          end
          return nil
     end
     helper_method :get_cur_instructor

     #populate the enrollments functionality with waitlist
     def fill_enrollments_with_waitlist
          all_courses = Course.all

          for course in all_courses do
               while course.capacity > Enrollment.where(course_id: course.id).count && Waitlist.where(course_id: course.id).count > 0 do
                    student_waitlist_to_be_enrolled = Waitlist.where(course_id: course.id).order("created_at ASC").first
                    enrolled_student = Enrollment.create!(:student_id => student_waitlist_to_be_enrolled.student_id , :course_id => student_waitlist_to_be_enrolled.course_id)
                    student_waitlist_to_be_enrolled.destroy
               end
          end
          check_status_for_all_courses
     end
     
     #check the status of all the courses
     def check_status_for_all_courses
          all_courses = Course.all

          for course in all_courses do
               total_enrollments = Enrollment.where(course_id: course.id).count
               total_waitlist = Waitlist.where(course_id: course.id).count
               
               if total_enrollments >= course.capacity
                    if total_waitlist >= course.waitlist_capacity
                         course.status = :closed
                    else
                         course.status = :waitlist
                    end
               elsif total_enrollments < course.capacity && (course.status == "closed" || course.status == "waitlist")
                    course.status = :open
               end
               course.save
          end
     end

     protected
          #permitted parameters that can be pased to the controller
          def configure_permitted_parameters
               devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:user_type, :email, :password, :name)}      
               devise_parameter_sanitizer.permit(:account_update, keys: [:name])      
          end

end
