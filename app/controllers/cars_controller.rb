class CarsController < ApplicationController
  before_action :require_login  #ログイン要求
  def index
    @run = Run.find(params[:run_id])

    # 仮データ：1〜8号車
    @cars = (1..8).to_a
  end
end
