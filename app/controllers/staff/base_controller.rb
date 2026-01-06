class Staff::BaseController < ApplicationController
  before_action :require_login
  before_action :require_staff

  private

  def require_staff
    unless current_user&.staff?
      redirect_to root_path, alert: "駅員権限が必要です"
    end
  end

  def debug_staff
    Rails.logger.debug "=== STAFF BASE ==="
    Rails.logger.debug "current_user: #{current_user&.login_id}"
    Rails.logger.debug "role: #{current_user&.role}"
  end
end
