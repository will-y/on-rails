class SessionsController < ApplicationController
  skip_before_action :is_authenticated

  def new

  end

  def create
    begin
      if User.authenticate(params[:username], params[:password])
        user = User.find_by(username: params[:username])
        session[:user_id] = user.id
        session[:admin] = user.admin
        redirect_to user_path(session[:user_id])
      else
        redirect_to new_sessions_path, alert: "Username or password incorrect!"
      end
    rescue Mongo::Error::NoServerAvailable, SocketError
      redirect_to root_path, notice: "Our Server Is Down"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_sessions_path, notice: "Logged Out"
  end
end
