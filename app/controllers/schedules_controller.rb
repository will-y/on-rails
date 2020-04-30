class SchedulesController < ApplicationController

  def index
    service = ScheduleService.new
    @schedule = service.getSchedule
  end
end

