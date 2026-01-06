class SeatsController < ApplicationController
  before_action :require_login #ログイン要求
  def index
    @run = Run.find(params[:run_id])
    @car = @run.cars.find(params[:car_id])

    @departure_station = Station.find(params[:departure_station_id])
    @arrival_station   = Station.find(params[:arrival_station_id])

    @seats = @car.seats.order(:row, :column)

    @unavailable_seat_ids =
      @seats.reject { |seat|
        seat.available_for?(
          run: @run,
          departure_station: @departure_station,
          arrival_station: @arrival_station
        )
      }.map(&:id)
  end
end
