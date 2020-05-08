class SchedulesController < ApplicationController

  def index
    service = ScheduleService.new
    if (!params[:origin] || !params[:time] || !params[:train] || !params[:destination])
	@schedule = service.getSchedule	
    else
    	@schedule = service.filter(params[:origin], params[:time], params[:train], params[:destination])
    end
  end

end

