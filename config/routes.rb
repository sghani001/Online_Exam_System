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
      get 'take'
    end

    resources :questions
  end


  resources :exam_outcomes, only: [:index, :show]
  resources :users, only: [:new, :create]
end
