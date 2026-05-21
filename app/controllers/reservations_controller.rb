class ReservationsController < ApplicationController
  before_action :require_login #ログイン要求
  before_action :set_own_reservation, only: [:show, :destroy]
  before_action :set_completed_reservation, only: [:complete]

  def confirm
    @run = Run.find(params[:run_id])
    @car = Car.find(params[:car_id])

    @departure_station = Station.find(params[:departure_station_id])
    @arrival_station   = Station.find(params[:arrival_station_id])

    if current_user.staff?
      holder_name = params[:holder_name].to_s
      if holder_name.length > 20
        redirect_to run_car_seats_path(
          @run,
          @car,
          seat_ids: params[:seat_ids],
          departure_station_id: params[:departure_station_id],
          arrival_station_id: params[:arrival_station_id],
          run_on: params[:run_on],
          time: params[:time],
          time_basis: params[:time_basis],
          seat_type: params[:seat_type],
          seat_error: "予約者名義は20文字以内で入力してください"
        )
        return
      end
    end

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
      holder_name: holder_name,
      is_issued: current_user.staff?
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
    @run   = @reservation.run
    @seats = @reservation.seats
    @car   = @seats.first.car
  end

  def show
  end

  def destroy
    if @reservation.is_issued?
      redirect_to user_reservation_path(@user, @reservation),
        alert: "発券済みの予約は削除できません"
    else
      @reservation.destroy
      redirect_to user_path(@user),
        notice: "予約を削除しました"
    end
  end

  private

  def set_own_reservation
    @user = current_user
    @reservation = current_user.reservations.find_by(id: params[:id])

    unless @reservation
      redirect_to user_path(current_user), alert: "権限がありません"
    end
  end

  def set_completed_reservation
    @reservation = current_user
      .reservations
      .includes(:run, :seats, :departure_station, :arrival_station)
      .find_by(id: params[:reservation_id])

    unless @reservation
      redirect_to user_path(current_user), alert: "権限がありません"
    end
  end

end
