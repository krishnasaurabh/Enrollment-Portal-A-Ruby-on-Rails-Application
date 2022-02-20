class ApplicationController < ActionController::Base
     before_action :configure_permitted_parameters , if: :devise_controller?
     before_action :authenticate_user!, unless: :devise_controller?
     before_action :check_student_instructor_registered, unless: :devise_controller?

     def is_student?
          user_signed_in? && current_user.user_type == "Student"
     end
     helper_method :is_student?

     def is_instructor?
          user_signed_in? && current_user.user_type == "Instructor"
     end
     helper_method :is_instructor?

     def is_admin?
          user_signed_in? && current_user.user_type == "Admin"
     end
     helper_method :is_admin?

     def check_student_instructor_registered
          if is_instructor?
               if !Instructor.exists?(user_id:current_user.id)
                    redirect_to new_instructor_path
               end
          end

          if is_student?
               if !Student.exists?(user_id:current_user.id)
                    redirect_to new_student_path
               end
          end
     end

     def get_cur_student
          if is_student?
               return Student.find_by(user_id: current_user.id)
          end
          return nil
     end
     helper_method :get_cur_student

     def get_cur_instructor
          if is_instructor?
               return Instructor.find_by(user_id: current_user.id)
          end
          return nil
     end
     helper_method :get_cur_instructor

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

          def configure_permitted_parameters
               devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:user_type, :email, :password, :name)}      
               devise_parameter_sanitizer.permit(:account_update, keys: [:name])      
          end

end
