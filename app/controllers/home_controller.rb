class HomeController < ApplicationController
  skip_before_action :is_authenticated

  def index
  end
end
