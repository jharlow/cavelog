class LogCaveCopiesController < ApplicationController
  def create
    cave_id = params[:log_cave_copy][:cave_id]
    cave = Cave.find(cave_id)
    @log_cave_copy = LogCaveCopy.new(log_cave_copy_params)
    @log = Log.find(params[:id])
    @log_cave_copy.log = @log
    @log_cave_copy.cave_title = cave.title

    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit caves on this log.")
    elsif !cave
      flash[:alert] = "That cave doesn't seem to exist!"
    elsif LogCaveCopy.find_by(log_id: @log.id, cave_id: cave_id)
      flash[:alert] = "This cave has already been logged on this log"
    elsif @log_cave_copy.save
      flash[:notice] = "Cave added successfully."
    else
      flash[:alert] = "Failed to add cave."
    end

    respond_to do |format|
      format.turbo_stream { rerender_cave_relevant_partials(@log) }
      format.html { redirect_to(edit_log_cave_copies_path(@log)) }
    end
  end

  def edit
    @log = Log.find(params[:id])

    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit caves on this log.")
    end

    @current_caves = @log.log_cave_copies.sort { |cc| cc.cave.present? ? 0 : 1 }
    logger.info(@current_caves)

    @available_caves = if params[:q].present?
      caves = Cave.where.not(id: @current_caves.pluck(:id)).search_by_text_or_location(params[:q])
      Kaminari.paginate_array(caves).page(params[:page]).per(10)
    else
      Cave
        .where
        .not(id: @current_caves.pluck(:cave_id))
        .page(params[:page])
        .per(10)
    end
  end

  def destroy
    @log = Log.find(params[:id])
    if @log.user != current_user
      redirect_to(log_path(@log), alert: "You are not authorized to edit caves on this log.")
    else
      @log_cave_copy = LogCaveCopy.find(params[:cave_id])
      if !@log_cave_copy.present?
        flash[:alert] = "Cave has not been added to this log!"
      elsif @log_cave_copy.destroy
        flash[:notice] = "Cave removed successfully."
      else
        flash[:alert] = "Failed to remove cave."
      end
    end

    respond_to do |format|
      format.turbo_stream { rerender_cave_relevant_partials(@log) }
      format.html { redirect_to(edit_log_cave_copies_path(@log)) }
    end
  end

  private

  def rerender_cave_relevant_partials(log)
    render(
      turbo_stream: [
        turbo_stream.replace("log_caves_#{log.id}", partial: "log_cave_copies/edit-form", locals: log_cave_context(log)),
        turbo_stream.replace("locations_visited", partial: "logs/locations-visited", locals: log_locations_context(log))
      ]
    )
  end

  def log_locations_context(log)
    { locations_data: @log.locations_data, log: @log }
  end

  def log_cave_context(log)
    current_caves = log.log_cave_copies.sort { |cc| cc.cave.present? ? 0 : 1 }
    available_caves = if params[:q].present?
      caves = Cave.search_by_text_or_location(params[:q])
      Kaminari.paginate_array(caves).page(params[:page]).per(10)
    else
      Cave
        .page(params[:page])
        .per(10)
    end

    { log: log, current_caves: current_caves, available_caves: available_caves }
  end

  def log_cave_copy_params
    params.require(:log_cave_copy).permit(:id, :log_id, :cave_id, :cave_title)
  end
end
