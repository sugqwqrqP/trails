class ReservationsController < ApplicationController
  before_action :require_login #ログイン要求
  def confirm
    @run = Run.find(params[:run_id])
    @car_id = params[:car_id]
    @seat = params[:seat]
  end

  def create
    redirect_to complete_reservations_path(
      run_id: params[:run_id],
      car_id: params[:car_id],
      seat: params[:seat]
    )
  end

  def complete
    @run = Run.find(params[:run_id])
    @car_id = params[:car_id]
    @seat = params[:seat]
  end
end
