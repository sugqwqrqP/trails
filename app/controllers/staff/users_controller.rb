class Staff::UsersController < Staff::BaseController
  def index
    @include_admins = params[:include_admins] == "1"

    @users =
      if @include_admins
        User.order(:id)
      else
        User.customers.order(:id)
      end

    if params[:login_id].present?
      @users = @users.where("login_id LIKE ?", "%#{params[:login_id]}%")
    end

    if params[:user_fullname].present?
      @users = @users.where("user_fullname LIKE ?", "%#{params[:user_fullname]}%")
    end
  end

  def show
    @user = User.find(params[:id])
    @reservations = @user.reservations.order(created_at: :desc)
  end
end
