class SchedulesController < ApplicationController

  def index
    @schedule = nil
    service = ScheduleService.new
    if (!params[:origin] || !params[:time] || !params[:destination])
      service.getSchedule(Proc.new { |x| setSchedule(x) })
    else
      service.filter(params[:origin], params[:time], params[:destination], Proc.new { |x| setSchedule(x) })
    end
  end

  def setSchedule(schedule)
    @schedule = schedule
  end

end

