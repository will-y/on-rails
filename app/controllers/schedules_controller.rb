class SchedulesController < ApplicationController

  def index
    service = ScheduleService.new
    @schedule = service.filter(params[:origin], params[:time], params[:train], params[:destination])
  end

end

