class Operator::RunsController < Operator::BaseController
  def index
    @runs = Run.order(run_on: :desc)
  end

  def show
    @run = Run.find(params[:id])
  end

  def new
    @run = Run.new
  end
  def create
    @run = Run.new(
      run_on: params[:run][:run_on],
      first_station_departure_time: params[:run][:first_station_departure_time],
      run_type_id: params[:run][:run_type_id],
      is_up: params[:run][:is_up]
    )

    if @run.save
      redirect_to operator_run_path(@run), notice: "便を作成しました"
    else
      flash.now[:alert] = @run.errors.full_messages.join(" / ")
      render :new
    end
  end

end
