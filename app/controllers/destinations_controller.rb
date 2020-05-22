class DestinationsController < ApplicationController
  def index
    method = params["commit"]
    service = ScheduleService.new

    case method
    when "Create"
      service.addStation(params["station"])
    when "Delete"
      service.deleteStation(params[:station][0])
    end
  end

  def new
    service = ScheduleService.new
    @stations = service.getStations
  end

  def edit

  end
end
