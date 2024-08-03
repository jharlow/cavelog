class CavesController < ApplicationController
  def index
    @caves = Cave.all
  end

  def show
    @cave = Cave.find(params[:id])
  end

  def new
    @cave = Cave.new
  end

  def create
    @cave = Cave.new(cave_params)
    if @cave.save
      redirect_to @cave
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @cave = Cave.find(params[:id])
  end

  def update
    @cave = Cave.find(params[:id])
    if @cave.update(cave_params)
      redirect_to @cave
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cave = Cave.find(params[:id])
    @cave.destroy
    redirect_to root_path, status: :see_other
  end

  private def cave_params
    params.require(:cave).permit(:title, :description)
  end
end
