class SessionsController < ApplicationController
  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      reset_session
      log_in user
      redirect_to user, status: :see_other
    else
      flash.now[:danger] = t "sessions.invalid_email_password_combination"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    flash[:success] = t("flash.logged_out")
    redirect_to root_path, status: :see_other
  end
end
