class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(login_id: params[:login_id])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      if user.staff?
        # 駅員は必ず staff 名前空間へ
        session.delete(:return_to)
        redirect_to staff_root_path
      else
        # 一般利用者のみ return_to を使う
        redirect_to session.delete(:return_to) || root_path
      end
    else
      flash.now[:alert] = "ログインIDまたはパスワードが違います"
      render :new
    end
  end

  def destroy
    reset_session #session.delete(:user_id)よりもこちらが定石らしい
    redirect_to root_path
  end
end
