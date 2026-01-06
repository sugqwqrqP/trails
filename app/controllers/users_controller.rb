class UsersController < ApplicationController
  before_action :require_login
  
  def new
  end

  def create
  end

  def show
    @user = User.find(params[:id])

    unless @user == current_user
      redirect_to root_path, alert: "権限がありません"
      return
    end

    @reservations = @user.reservations
      .includes(:run, :departure_station, :arrival_station)
      .order(created_at: :desc)
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
