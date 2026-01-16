class Staff::ReservationsController < Staff::BaseController
  before_action :require_login
  before_action :require_staff

  def show
    @reservation = Reservation.find(params[:id])
  end

  def issue
    reservation = Reservation.find(params[:id])

    if reservation.is_issued?
      redirect_to staff_reservation_path(reservation),
                  alert: "すでに発券済みです"
      return
    end

    reservation.update!(is_issued: true)

    redirect_to staff_reservation_path(reservation),
                notice: "発券しました"
  end

  def destroy
    reservation = Reservation.find(params[:id])
    user = reservation.user

    if reservation.is_issued?
      redirect_to staff_reservation_path(reservation),
                  alert: "発券済みの予約は削除できません"
    else
      reservation.destroy
      redirect_to staff_user_path(user),
            notice: "予約を削除しました（利用者：#{user.user_fullname}）"
    end
  end
end
