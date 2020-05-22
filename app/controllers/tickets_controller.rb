class TicketsController < ApplicationController

  def new
    service = ScheduleService.new
    @ticket = Ticket.new
    puts params["time"][0]
    puts params["arrivingat"]
    puts params["goingto"]
    @schedule = service.get_row(params["arrivingat"], params["time"][0], params["goingto"])
    @schedule.each do |row|
      puts "!!!!!!!!!!!!!!!!!!1"
      puts row
      @price = row["price"]
      @going_to = row["goingto"]
    end

    @states = %w(Alaska Alabama Arkansas American\ Samoa Arizona California Colorado Connecticut District\ of\ Columbia Delaware Florida Georgia Guam Hawaii Iowa Idaho Illinois Indiana Kansas Kentucky Louisiana Massachusetts Maryland Maine Michigan Minnesota Missouri Mississippi Montana North\ Carolina North\ Dakota Nebraska New\ Hampshire New\ Jersey New\ Mexico Nevada New\ York Ohio Oklahoma Oregon Pennsylvania Puerto\ Rico Rhode\ Island South\ Carolina South\ Dakota Tennessee Texas Utah Virginia Virgin\ Islands Vermont Washington Wisconsin West\ Virginia Wyoming)
    begin
      @user = User.find(@current_user)
    rescue
      redirect_to root_path, notice: "Login Servers Down"
      return
    end
  end

  def create
    #@ticket = Ticket.new(ticket_params)
    #@current_user.tickets.push(@ticket)
    #@ticket.user = @user
    #@ticket.save
    #@current_user.save
    ticket_params_temp = ticket_params
    @price = ticket_params_temp['price'].to_f * ticket_params_temp['quantity'].to_i
    if ticket_params_temp['first_class'] == '1'
      @price = @price * 2
    end
    @price = @price.round(2)
    ticket_params_temp['price'] = @price
    begin
      User.find(@current_user).tickets.create(ticket_params_temp)
    rescue
      redirect_to root_path, notice: "Login Servers Down"
      return
    end
    redirect_to schedules_path
  end

  def edit
    begin
      @user = User.find(@current_user)
      @ticket = Ticket.where(user_id: @current_user["$oid"], _id: params[:id]).first

    rescue
      redirect_to root_path, notice: "Login Servers Down"
      return
    end
    @price = @ticket.price
    @destination = @ticket.destination
    @origin = @ticket.origin
    @time = @ticket.time
    @train = @ticket.train
    @quantity = @ticket.quantity
  end

  def update
    begin
      @ticket = Ticket.find(params[:id])
    rescue
      redirect_to root_path, notice: "Login Servers Down"
      return
    end

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
    Log.add_to_mongo_log("mongo", @ticket, "update", [quantity: params[:ticket][:quantity], first_class: params[:ticket][:first_class], price: @price])
    # @ticket.update(quantity: params[:ticket][:quantity], first_class: params[:ticket][:first_class], price: @price)

    redirect_to user_path(@current_user["$oid"])
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to root_path, notice: "Login Servers Down"
      return
    end
  end

  def destroy
    @ticket = Ticket.where(user_id: @current_user["$oid"], _id: params[:id]).delete
    redirect_to user_path(id: @current_user["$oid"]), notice: "Ticket Deleted"
  end

  private

  def ticket_params
    params.require(:ticket).permit(:origin, :destination, :quantity, :price, :first_class, :time, :user)
  end

end
