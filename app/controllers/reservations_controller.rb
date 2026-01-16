class ReservationsController < ApplicationController
  before_action :require_login #ログイン要求

  def confirm
    @run = Run.find(params[:run_id])
    @car = Car.find(params[:car_id])

    @departure_station = Station.find(params[:departure_station_id])
    @arrival_station   = Station.find(params[:arrival_station_id])

    seat_ids =
      case params[:seat_ids]
      when String
        params[:seat_ids].split(",")
      else
        params[:seat_ids]
      end

    @seats = Seat.where(id: seat_ids)

    @departure_time = @run.departure_time_at(@departure_station)
    @arrival_time   = @run.arrival_time_at(@arrival_station)

    @holder_name = params[:holder_name]

    # 料金計算
    @fee_per_seat = @run.fee_per_seat(
      departure_station: @departure_station,
      arrival_station:   @arrival_station,
      car_type:          @car.car_type
    )

    @total_fee = @fee_per_seat * @seats.size
  end

  def create
    run = Run.find(params[:run_id])
    departure_station = Station.find(params[:departure_station_id])
    arrival_station   = Station.find(params[:arrival_station_id])

    seat_ids = Array(params[:seat_ids])
    seats = Seat.where(id: seat_ids)

    # 空席チェック
    unavailable_seats = seats.reject do |seat|
      seat.available_for?(
        run: run,
        departure_station: departure_station,
        arrival_station: arrival_station
      )
    end

    if unavailable_seats.any?
      flash[:alert] = "申し訳ありません。選択した席は既に予約されています。再度選択してください。"
      redirect_to run_car_seats_path(
        run,
        car_id: seats.first.car_id,
        departure_station_id: params[:departure_station_id],
        arrival_station_id: params[:arrival_station_id],
        seat_error: "申し訳ありません。選択した席は既に予約されています。再度選択してください。"
      )
      return
    end

    holder_name =
      if current_user.staff?
        params[:holder_name]
      else
        current_user.user_fullname
      end

    @reservation = Reservation.new(
      user: current_user,
      run: run,
      departure_station: departure_station,
      arrival_station: arrival_station,
      holder_name: holder_name
    )

    unless @reservation.save
      # confirm で使う変数を必ず再セット
      @run = run
      @departure_station = departure_station
      @arrival_station = arrival_station
      @seats = seats
      @car = seats.first.car
      @holder_name = holder_name
      @departure_time = run.departure_time_at(departure_station)
      @arrival_time   = run.arrival_time_at(arrival_station)
      @fee_per_seat = run.fee_per_seat(
        departure_station: departure_station,
        arrival_station: arrival_station,
        car_type: @car.car_type
      )
      @total_fee = @fee_per_seat * seats.size

      flash.now[:alert] = @reservation.errors.full_messages.join(" / ")
      render :confirm
      return
    end

    seats.each do |seat|
      ReservationSeat.create!(
        reservation: @reservation,
        seat: seat
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
