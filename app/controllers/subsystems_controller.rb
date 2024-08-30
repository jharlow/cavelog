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
      redirect_to(cave_subsystem_url(@cave, @subsystem))
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @subsystem = Subsystem.find(params[:id])
  end

  def update
    @subsystem = Subsystem.find(params[:id])

    if @subsystem.update(subsystem_params)
      redirect_to(cave_subsystem_url(@subsystem.cave, @subsystem))
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @subsystem = Subsystem.find(params[:id])
    @subsystem.destroy
    redirect_to(cave_path(@subsystem.cave), status: :see_other)
  end

  private def subsystem_params
    params.require(:subsystem).permit(:title, :description, :cave)
  end
end
