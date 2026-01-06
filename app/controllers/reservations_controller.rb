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
    @reservation = Reservation.create!(
      user: current_user,
      run_id: params[:run_id],
      departure_station_id: params[:departure_station_id],
      arrival_station_id: params[:arrival_station_id],
      holder_name: current_user.user_fullname
    )

    seat_ids =
      case params[:seat_ids]
      when String
        params[:seat_ids].split(",")
      else
        params[:seat_ids]
      end

    seat_ids.each do |seat_id|
      ReservationSeat.create!(
        reservation: @reservation,
        seat_id: seat_id
      )
    end

    redirect_to complete_reservations_path(
      run_id: @reservation.run_id,
      car_id: params[:car_id],
      seat_ids: seat_ids
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
