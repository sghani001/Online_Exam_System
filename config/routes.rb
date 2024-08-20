Rails.application.routes.draw do
  root to: 'exams#index'
  
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :exams do
    member do
      post 'approve'
      post 'cancel'
      post 'request_approval'
      get 'next_question'
      get 'take', to: 'exams#take'
      post 'submit'
    end

    resources :questions
    resources :student_answers, only: [:create]
  end


  resources :exam_outcomes, only: [:index, :show]
  resources :users, only: [:new, :create]
end
