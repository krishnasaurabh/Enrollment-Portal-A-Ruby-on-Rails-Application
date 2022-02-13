Rails.application.routes.draw do
  resources :waitlists
  resources :enrollments
  resources :courses
  resources :admins
  resources :students
  resources :instructors
  devise_for :users
  get 'home/index'
  root 'home#index'
  get '/enroll_course/:id' , to: 'enrollments#enroll_course', as: 'enroll_course'
  get '/waitlist_course/:id' , to: 'waitlists#waitlist_course', as: 'waitlist_course'
  get '/courses/:id/enrolled_students' , to: 'courses#enrolled_students', as: 'enrolled_students'
  get '/courses/:id/waitlisted_students' , to: 'courses#waitlisted_students', as: 'waitlisted_students'
  get '/courses/:course_id/enroll_course_for_student/', to: 'enrollments#show_enroll_course_for_student', as: 'show_enroll_course_for_student'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
