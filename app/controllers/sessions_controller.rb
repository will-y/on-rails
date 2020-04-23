class SessionsController < ApplicationController
  skip_before_action :is_authenticated

  def new

  end

  def create
    if User.authenticate(params[:username], params[:password])
      session[:user_id] = User.find_by(username: params[:username]).id
      redirect_to users_path
    else
      redirect_to new_session_path, alert: "Username or password incorrect!"
    end
  end
end