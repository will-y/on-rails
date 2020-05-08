class TicketsController < ApplicationController

  def new
    service = ScheduleService.new
    @ticket = Ticket.new
    @schedule = service.get_row(params["arrivingat"], params["time"], params["train"])
    @schedule.each do |row|
        @price = row["price"]
        @going_to = row["goingto"]
    end

    @states = %w(Alaska Alabama Arkansas American\ Samoa Arizona California Colorado Connecticut District\ of\ Columbia Delaware Florida Georgia Guam Hawaii Iowa Idaho Illinois Indiana Kansas Kentucky Louisiana Massachusetts Maryland Maine Michigan Minnesota Missouri Mississippi Montana North\ Carolina North\ Dakota Nebraska New\ Hampshire New\ Jersey New\ Mexico Nevada New\ York Ohio Oklahoma Oregon Pennsylvania Puerto\ Rico Rhode\ Island South\ Carolina South\ Dakota Tennessee Texas Utah Virginia Virgin\ Islands Vermont Washington Wisconsin West\ Virginia Wyoming)
    @user = @current_user
  end

  def create
    #@ticket = Ticket.new(ticket_params)
    #@current_user.tickets.push(@ticket)
    #@ticket.user = @user
    #@ticket.save
    #@current_user.save
    @current_user.tickets.create(ticket_params)
    redirect_to schedules_path
  end

  private
    def ticket_params
      params.require(:ticket).permit(:origin, :destination, :train, :price, :first_class, :time, :user)
    end
end
