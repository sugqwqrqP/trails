class Staff::UsersController < Staff::BaseController
  def index
    @users = User.order(:id)
  end

  def show
    @user = User.find(params[:id])
    @reservations = @user.reservations.order(created_at: :desc)
  end
end
