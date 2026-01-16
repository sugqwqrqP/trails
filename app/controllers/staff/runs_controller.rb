class Staff::RunsController < Staff::BaseController
  before_action :require_login
  before_action :require_staff

  def index
    result = RunSearchService.call(
      params: params,
      display_limit: nil,
      include_availability: true,
      enable_pager: false
    )

    @results = result[:results]
    @errors = result[:errors]
    @departure_station = result[:departure_station]
    @arrival_station = result[:arrival_station]
  end

  def show
    @run = Run.find(params[:id])

    if params[:departure_station_id].present? && params[:arrival_station_id].present?
      @departure_station = Station.find_by(id: params[:departure_station_id])
      @arrival_station   = Station.find_by(id: params[:arrival_station_id])
    end
    @reservations = @run.reservations
                        .includes(:seats, :departure_station, :arrival_station)
                        .order(created_at: :desc)
  end

end
