class ApplicationController < ActionController::Base
     before_action :configure_permitted_parameters , if: :devise_controller?
     before_action :authenticate_user!, unless: :devise_controller?


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
     
     protected

          def configure_permitted_parameters
               devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:user_type, :email, :password, :name)}      
               devise_parameter_sanitizer.permit(:account_update, keys: [:name])      
          end

end
