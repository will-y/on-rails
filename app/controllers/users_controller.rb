class UsersController < ApplicationController
  skip_before_action :is_authenticated, only: [:new, :create]
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path
    else
      render action: "new"
    end
  end

  def edit
    redirect_to root_path if session[:user_id]["$oid"] != params[:id]
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:password] == ""
      @user.update(name: params[:user][:name], username: params[:user][:username], phone: params[:user][:phone], email: params[:user][:email])
    else
      @user.update(name: params[:user][:name], username: params[:user][:username], phone: params[:user][:phone], email: params[:user][:email], password: params[:user][:password])
    end
    redirect_to user_path
  end

  private
  def user_params
    params.require(:user).permit(:name, :username, :password, :phone, :email)
  end
end