class SeatsController < ApplicationController
  before_action :require_login #ログイン要求
  def index
    @run = Run.find(params[:run_id])
    @car_id = params[:car_id]

    # 仮データ：座席ラベル
    @seats = %w[A1 A2 A3 A4 A5 B1 B2 B3 B4 B5 C1 C2 C3 C4 C5]
  end
end
