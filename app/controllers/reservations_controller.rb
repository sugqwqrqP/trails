class ReservationsController < ApplicationController
  before_action :require_login #ログイン要求
  def confirm
    @run = Run.find(params[:run_id])
    @car = Car.find(params[:car_id])

    seat_ids =
      case params[:seat_ids]
      when String
        params[:seat_ids].split(",")
      else
        params[:seat_ids]
      end

    @seats = Seat.where(id: seat_ids)
  end

  def create
    redirect_to complete_reservations_path(
      run_id: params[:run_id],
      car_id: params[:car_id],
      seat_ids: params[:seat_ids]
    )
  end

  def complete
    @run = Run.find(params[:run_id])
    @car = Car.find(params[:car_id])

    seat_ids =
      case params[:seat_ids]
      when String
        params[:seat_ids].split(",")
      else
        params[:seat_ids]
      end

    @seats = Seat.where(id: seat_ids)
  end
end
