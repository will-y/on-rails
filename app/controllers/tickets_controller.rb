class TicketsController < ApplicationController

  def new
    service = ScheduleService.new
    @ticket = Ticket.new
    @schedule = service.get_row(params["arrivingat"], params["time"], params["train"])
    @price = @schedule[:price]
    @price_1st = @schedule[:price_1st]
    @going_to = @schedule[:goingto]
  end
end
