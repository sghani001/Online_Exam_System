class Users::RegistrationsController < Devise::RegistrationsController
  private

  # Permit additional parameters for user registration
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :user_type,:name)
  end

  # Permit additional parameters for account update
  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password,:name)
  end
end
