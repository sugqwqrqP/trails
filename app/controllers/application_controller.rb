class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    return @current_user if defined?(@current_user)       # current_userが未定義なら2行目に入ってDBを叩く
    @current_user = User.find_by(id: session[:user_id])   # 同じリクエスト内で何度もDBを叩かないための実装（メモ化）
  end

  def logged_in?
    current_user.present?
  end
end
