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
      reservation_id: @reservation.id
    )
  end

  def complete
    @reservation = Reservation
                    .includes(:run, :seats, :departure_station, :arrival_station)
                    .find(params[:reservation_id])

    @run   = @reservation.run
    @seats = @reservation.seats
    @car   = @seats.first.car
  end

  def show
    @user = User.find(params[:user_id])
    @reservation = @user.reservations.find(params[:id])
  end

  def destroy
    @user = User.find(params[:user_id])
    reservation = @user.reservations.find(params[:id])

    if reservation.is_issued?
      redirect_to user_reservation_path(@user, reservation),
        alert: "発券済みの予約は削除できません"
    else
      reservation.destroy
      redirect_to user_path(@user),
        notice: "予約を削除しました"
    end
  end

end
