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

  private
  def user_params
    params.require(:user).permit(:name, :username, :password, :phone, :email)
  end
end