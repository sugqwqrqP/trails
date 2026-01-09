class Operator::BaseController < ApplicationController
  before_action :require_login
  before_action :require_operator

  private

  def require_operator
    unless current_user&.operator?
      redirect_to root_path, alert: "運行管理者権限が必要です"
    end
  end
end
