class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate(params.dig(:session, :password))
      if user.activated?
        handle_session_management(user)
      else
        handle_inactive_user
      end
    else
      handle_invalid_credentials
    end
  end

  def destroy
    log_out
    flash[:success] = t("flash.logged_out")
    redirect_to root_path, status: :see_other
  end

  private

  def handle_session_management user
    forwarding_url = session[:forwarding_url]
    reset_session
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    log_in user
    redirect_to forwarding_url || user
  end

  def handle_inactive_user
    flash[:warning] = t("account_activations.not_activated")
    redirect_to root_url, status: :see_other
  end

  def handle_invalid_credentials
    flash.now[:danger] = t("sessions.invalid_email_password_combination")
    render :new, status: :unprocessable_entity
  end
end
