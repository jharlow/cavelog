class CavesController < ApplicationController
  def index
    if params[:q].present?
      geocoded_caves = geocodable?(params[:q]) ? Cave.near(params[:q]) : Cave.none
      title_caves = Cave.fuzzy_search(params[:q]).records
      @caves = (geocoded_caves + title_caves).uniq
    else
      @caves = Cave.all
    end
  end

  def show
    @cave = Cave.find(params[:id])
    @user_logs = @cave.logs.where(user: current_user)
  end

  def new
    @cave = Cave.new
  end

  def create
    @cave = Cave.new(cave_params)
    if @cave.save
      redirect_to(@cave)
    else
      render(:new, status: :unprocessable_entity)
    end
  end

  def edit
    @cave = Cave.find(params[:id])
  end

  def update
    @cave = Cave.find(params[:id])
    if @cave.update(cave_params)
      redirect_to(@cave)
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  def destroy
    @cave = Cave.find(params[:id])
    @cave.destroy
    redirect_to(root_path, status: :see_other)
  end

  private

  def cave_params
    params.require(:cave).permit(:title, :description, :longitude, :latitude)
  end

  def geocodable?(query)
    # Attempt to geocode the query to see if it returns a valid location
    results = Geocoder.search(query)
    results.present? && results.first.coordinates.present?
  rescue
    false
  end
end
