class SchedulesController < ApplicationController

  def index
    method = params["commit"]
    service = ScheduleService.new

    case method
    when "Filter"
      @schedule = nil
      if (!params[:origin] || !params[:time] || !params[:destination])
        @schedule = service.getSchedule()
      else
        @schedule = service.filter(params[:origin], params[:time], params[:destination])
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
    puts @stations
  end

end