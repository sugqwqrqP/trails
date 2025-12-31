class SeatsController < ApplicationController
  before_action :require_login #ログイン要求
  def index
    @run = Run.find(params[:run_id])
    @car_id = params[:car_id]

    # 指定席の座席構成（ガワ用）
    @rows = (1..8).to_a
    @cols = %w[A B C D E]
  end
end
