Rails.application.routes.draw do
  root to: 'home#index'
  
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end



  namespace :admin do
    root to: 'exams#index'
    resources :exams do
      member do
        post 'approve'
        post 'cancel'
      end

      resources :questions
    end

    resources :users, only: [:new, :create]
    resources :exam_outcomes, only: [:index, :show]
  end


  namespace :teacher do
    root to: 'exams#index'
    resources :exams do
      member do
        post 'cancel'
        post 'request_approval'
        post 'submit'
        get 'review_exam'
        post 'assign_marks'
      end
      collection do
        get 'taken_exams'
      end
      resources :review_answers, only: [:index] do
        collection do
          patch :update_marks
        end
      end

      resources :questions
    end

    resources :exam_outcomes, only: [:index, :show]
  end



  namespace :student do
    root to: 'exams#index'  # Root path for students
    resources :exams, only: [:index, :show] do
      member do
        get 'take', to: 'exams#take'
        post 'next_question'
        post 'submit'
      end

      resources :student_answers, only: [:create]
    end

    resources :exam_outcomes, only: [:index, :show]
  end

end
