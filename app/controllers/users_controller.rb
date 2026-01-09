class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])

    if @user != current_user
      redirect_to root_path, alert: "権限がありません"
      return
    end

    @reservations = @user.reservations.includes(
      :run,
      :departure_station,
      :arrival_station,
      reservation_seats: :seat
    )
  end

  def update
    if @user.update(update_user_params)
      redirect_to user_path(@user), notice: "会員情報を更新しました"
    else
      render :edit
    end
  end
  
  def destroy
  end

  private

  def user_params
    params.require(:user).permit(
      :login_id,
      :user_fullname,
      :password,
      :password_confirmation
    )
  end

    def set_user
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to root_path, alert: "権限がありません"
    end
  end

  def update_user_params
    params.require(:user).permit(
      :user_fullname,
      :password,
      :password_confirmation
    )
  end

end
