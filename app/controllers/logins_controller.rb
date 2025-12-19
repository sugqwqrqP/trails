class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(login_id: params[:login_id])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path
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
