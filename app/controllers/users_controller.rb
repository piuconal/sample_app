class UsersController < ApplicationController
  # before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :logged_in_user, except: %i(new create show)
  before_action :find_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy
  before_action :set_user, only: %i(followers following)

  def index
    items_per_page = Settings.pagy.items
    @pagy, @users = pagy(User.recent, items: items_per_page)
  end

  def show
    @page, @microposts = pagy(@user.microposts, items: Settings.pagy.items)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # reset_session
      # log_in @user
      # flash[:success] = t("flash.users.welcome")
      # redirect_to @user

      @user.send_activation_email
      flash[:info] = t("flash.info.check_email")
      redirect_to root_url, status: :see_other
    else
      flash.now[:error] = @user.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t("flash.users.updated")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t("flash.users.deleted")
    else
      flash[:danger] = t("flash.users.delete_failed")
    end
    redirect_to users_path
  end

  def followers
    @title = "Followers"
    @pagy, @users = pagy @user.followers, items: Settings.pagy.items
    render :show_follow
  end

  def following
    @title = "Following"
    @pagy, @users = pagy @user.following, items: Settings.pagy.items
    render :show_follow
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:notice] = "User not found"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit(:name, :email,
                                 :password, :password_confirmation)
  end

  def find_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:danger] = t("flash.users.not_found")
    redirect_to root_url
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("flash.users.login_required")
    redirect_to login_url
  end

  def correct_user
    return if current_user?(@user)

    flash[:error] = t("flash.users.edit_not_permitted")
    redirect_to root_url
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
