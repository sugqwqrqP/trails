class CarsController < ApplicationController
  before_action :require_login  #ログイン要求
  def index
    @run = Run.find(params[:run_id])

    @cars = @run.cars
                .includes(:car_type)
                .order(:number)
  end
end
