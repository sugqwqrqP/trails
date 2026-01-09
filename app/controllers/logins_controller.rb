class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(login_id: params[:login_id])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      case user.role
      when "staff"
        session.delete(:return_to)
        redirect_to staff_root_path

      when "operator"
        session.delete(:return_to)
        redirect_to operator_root_path

      else
        # 一般利用者のみ return_to を考える
        redirect_to session.delete(:return_to) || root_path
      end
    else
      flash.now[:alert] = "ログインIDまたはパスワードが違います"
      render :new
    end
  end

  def destroy
    reset_session #session.delete(:user_id)よりもこちらが定石らしい
    redirect_to root_path, notice: "ログアウトしました"
  end
end
