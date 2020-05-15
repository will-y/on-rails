class TicketsController < ApplicationController

  def new
    service = ScheduleService.new
    @ticket = Ticket.new
    service.get_row(params["arrivingat"], params["time"], params["goingto"],Proc.new { |x| setSchedule(x) })
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
    ticket_params_temp = ticket_params
    puts( ticket_params_temp)
    @price = ticket_params_temp['price'].to_f * ticket_params_temp['quantity'].to_i
    if ticket_params_temp['first_class'] == '1'
      @price = @price * 2
    end
    @price = @price.round(2)
    ticket_params_temp['price'] = @price
    puts( @price)
    @current_user.tickets.create(ticket_params_temp)
    redirect_to schedules_path
  end

  def edit
    @ticket = Ticket.where(user_id: @current_user, _id: params[:id]).first
    @user = @current_user
    @price = @ticket.price
    @destination = @ticket.destination
    @origin = @ticket.origin
    @time = @ticket.time
    @train = @ticket.train
    @quantity = @ticket.quantity
  end

  def update
    @ticket = Ticket.find(params[:id])

    @price = @ticket.price.to_f

    if @ticket.first_class
        @price = @price / 2
    end

    if @ticket.quantity.nil?
        @quantity = 1
    else
        @quantity = @ticket.quantity
    end

    @price = @price / @quantity
    if params[:ticket][:first_class] == "1"
        @price = @price * 2
    end

    @price = (@price * params[:ticket][:quantity].to_i).round(2)

    @ticket.update(quantity: params[:ticket][:quantity], first_class: params[:ticket][:first_class], price: @price)

    redirect_to user_path(@current_user)
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @ticket = Ticket.where(user_id: @current_user, _id: params[:id]).delete
    redirect_to user_path(@current_user), notice: "Ticket Deleted"
  end

  private
    def ticket_params
      params.require(:ticket).permit(:origin, :destination, :quantity, :price, :first_class, :time, :user)
    end

  def setSchedule(schedule)
    @schedule = schedule
  end
end
