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
end
