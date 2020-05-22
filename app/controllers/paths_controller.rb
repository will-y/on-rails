class PathsController < ApplicationController
  def index
    method = params[:commit]

    if method == "Search"
      if params[:origin][0] == params[:destination][0]
        redirect_to new_path_path, notice: "Please Select Differing Stations"
      else
        service = ScheduleService.new
        @results = service.findPath(params[:origin][0], params[:destination][0])
      end

    end
  end

  def new
    service = ScheduleService.new
    @stations = service.getStations
  end
end
