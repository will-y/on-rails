class PathsController < ApplicationController
  def index
    method = params[:commit]

    if method == "Search"
      service = ScheduleService.new
      @results = service.findPath(params[:origin][0], params[:destination][0])

    end
  end

  def new
    service = ScheduleService.new
    @stations = service.getStations
  end
end
