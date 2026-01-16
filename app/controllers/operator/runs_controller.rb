class Operator::RunsController < Operator::BaseController
  def index
    result = RunSearchService.call(
      params: params,
      display_limit: nil,
      include_availability: true,
      enable_pager: false
    )

    @results = result[:results]
    @errors = result[:errors]
  end

  def show
    @run = Run.find(params[:id])
  end

  def new
    @run = Run.new
  end

  def create
    run = RunCreationService.create!(
      {
        run_on: params[:run][:run_on],
        first_station_departure_time: params[:run][:first_station_departure_time],
        run_type_id: params[:run][:run_type_id],
        is_up: params[:run][:is_up]
      },
      context: :manual_create
    )

    redirect_to operator_run_path(run), notice: "便を作成しました"

  rescue ActiveRecord::RecordInvalid => e
    @run = e.record
    flash.now[:alert] = @run.errors.full_messages.join(" / ")
    render :new
  end
end
