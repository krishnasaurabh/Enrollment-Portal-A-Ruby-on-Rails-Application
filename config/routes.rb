Rails.application.routes.draw do
  resources :enrollments
  resources :courses
  resources :admins
  resources :students
  resources :instructors
  devise_for :users
  get 'home/index'
  root 'home#index'
  get '/enroll_course/:id' , to: 'enrollments#enroll_course', as: 'enroll_course'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
