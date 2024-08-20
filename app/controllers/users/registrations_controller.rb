class Users::RegistrationsController < Devise::RegistrationsController
  
  before_action :authenticate_user!
  before_action :ensure_admin!, only: [:new, :create]


  skip_before_action :require_no_authentication, only: [:new, :create]

  def create
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      flash[:notice] = "User was successfully created."
      redirect_to root_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
  
  
  private
  def ensure_admin!
    redirect_to(root_path, alert: 'You are not authorized to perform this action.') unless current_user.user_type == 'admin'
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :user_type,:name)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password,:name)
  end
end
