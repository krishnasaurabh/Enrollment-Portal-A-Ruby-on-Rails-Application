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

     protected

          def configure_permitted_parameters
               devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:user_type, :email, :password, :name)}      
               devise_parameter_sanitizer.permit(:account_update, keys: [:name])      
          end

end
