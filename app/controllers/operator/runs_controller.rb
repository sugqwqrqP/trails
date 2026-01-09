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
    @run = Run.new(run_params)

    if @run.save
      redirect_to operator_run_path(@run), notice: "便を作成しました"
    else
      flash.now[:alert] = @run.errors.full_messages.join(" / ")
      render :new
    end
  end

  private

  def run_params
    params.require(:run).permit(
      :display_name,
      :run_on,
      :run_type_id # ← 今のERに合わせて。なければ後で直す
    )
  end
end
