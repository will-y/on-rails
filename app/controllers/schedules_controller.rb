class SchedulesController < ApplicationController

  def index
    @schedule = nil
    service = ScheduleService.new
    if (!params[:origin] || !params[:time] || !params[:destination])
      @schedule = service.getSchedule()
    else
      @schedule = service.filter(params[:origin], params[:time], params[:destination])
    end
  end

end