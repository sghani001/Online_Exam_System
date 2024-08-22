class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  def index
    if user_signed_in?
      case current_user.user_type
      when 'admin'
        redirect_to admin_root_path
      when 'teacher'
        redirect_to teacher_root_path
      when 'student'
        redirect_to student_root_path 
      end
    else
      redirect_to new_user_session_path
    end
  end
end
