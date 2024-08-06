class SubsystemsController < ApplicationController
  def show
    @subsystem = Subsystem.find(params[:id])
  end

  def new
    @subsystem = Subsystem.new
    @cave = Cave.find(params[:cave_id])
  end

  def create
    @cave = Cave.find(params[:cave_id])
    @subsystem = @cave.subsystems.new(subsystem_params)
    if @subsystem.save
      redirect_to cave_subsystem_url(@cave, @subsystem)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def subsystem_params
    params.require(:subsystem).permit(:title, :description, :cave)
  end
end
