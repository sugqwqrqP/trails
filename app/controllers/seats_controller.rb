class SeatsController < ApplicationController
  before_action :require_login #ログイン要求
  def index
    @run = Run.find(params[:run_id])
    @car = @run.cars.find(params[:car_id])

    @seats = @car.seats.order(:row, :column)
  end
end
