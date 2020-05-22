class SchedulesController < ApplicationController

  def index
    method = params["commit"]
    service = ScheduleService.new
    @schedule = service.getSchedule()
    @stations = service.getStations

    case method
    when "Filter"
      @schedule = nil
      if (!params[:origin][0] || !params[:destination][0])
        @schedule = service.getSchedule()
      else
        @schedule = service.filter(params[:origin][0], params[:time], params[:destination][0])
      end
    when "Create"
      puts params
      puts "params: #{params[:origin][0]}, #{params[:time]["(4i)"]}:#{params[:time]["(5i)"]}, #{params[:destination][0]},  #{params[:price][0]}"
      service.addToSchedule(params[:origin][0], "#{params[:time]["(4i)"]}:#{params[:time]["(5i)"]}", params[:destination][0], params[:price][0])
      puts 'creating'
    when "Delete"
      puts 'deleting'
    end
  end

  def new
    service = ScheduleService.new
    @stations = service.getStations
  end

end