require 'pp'

class SchedulesController < ApplicationController

  def index
    method = params["commit"]
    service = ScheduleService.new

    case method
    when "Filter"
      @schedule = nil
      if (!params[:origin][0] || !params[:destination][0])
        @schedule = service.getSchedule()
      else

        puts "!!!!!!!!!!!!!!!!!"
        puts params[:origin][0]
        puts params[:destination][0]
        @schedule = service.filter(params[:origin][0], "", params[:destination][0])
        pp @schedule
      end
    when "Create"
      if params[:origin][0] == params[:destination][0]
        redirect_to new_schedule_path, notice: "Cannot have a route from #{params[:origin][0]} to #{params[:destination][0]}"
      else
        @schedule = service.getSchedule()
        service.addToSchedule(params[:origin][0], "#{params[:time]["(4i)"]}:#{params[:time]["(5i)"]}", params[:destination][0], params[:price])
      end

    when "Delete"

      @schedule = service.getSchedule()
      service.removeFromSchedule(params[:origin][0], "#{params[:time]["(4i)"]}:#{params[:time]["(5i)"]}", params[:destination][0])
    else
      @schedule = service.getSchedule()
    end

    @stations = service.getStations
  end

  def new
    service = ScheduleService.new
    @stations = service.getStations
  end

end