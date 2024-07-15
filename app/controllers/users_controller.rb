class UsersController < ApplicationController
  before_action :find_user, only: :show

  def show
    return if @user

    flash[:warning] = t("flash.users.not_found")
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      reset_session
      log_in @user
      flash[:success] = t("flash.users.welcome")
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = User.find_by id: params[:id]
  end

  def user_params
    params.require(:user).permit(User::USER_PARAMS)
  end
end
