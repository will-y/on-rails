class UsersController < ApplicationController
  skip_before_action :is_authenticated, only: [:new, :create]
  def index
    redirect_to root_path if !@admin
    @users = User.all
  end

  def show
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to root_path, notice: "Login Servers Down"
    end

    if @user.id.to_s != @current_user["$oid"].to_s
      redirect_to root_path
    end
  end

  def new
    @user = User.new
    @states = %w(Alaska Alabama Arkansas American\ Samoa Arizona California Colorado Connecticut District\ of\ Columbia Delaware Florida Georgia Guam Hawaii Iowa Idaho Illinois Indiana Kansas Kentucky Louisiana Massachusetts Maryland Maine Michigan Minnesota Missouri Mississippi Montana North\ Carolina North\ Dakota Nebraska New\ Hampshire New\ Jersey New\ Mexico Nevada New\ York Ohio Oklahoma Oregon Pennsylvania Puerto\ Rico Rhode\ Island South\ Carolina South\ Dakota Tennessee Texas Utah Virginia Virgin\ Islands Vermont Washington Wisconsin West\ Virginia Wyoming)
  end

  def create
    @user = User.new(user_params)
    if User.validate_username(user_params[:username])
      Log.add_to_mongo_log("mongo", @user, "save", [])
      redirect_to root_path
      # begin
      #   if @user.save
      #     redirect_to root_path
      #   else
      #
      #     render action: "new"
      #   end
      # rescue Mongo::Error::NoServerAvailable, SocketError
      #   Log.add_to_mongo_log("mongo", @user, "save")
      #   redirect_to root_path
      # end
    else
      redirect_to new_user_path, alert: "Username Taken"
    end
  end

  def edit
    redirect_to root_path if session[:user_id]["$oid"] != params[:id]
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to root_path, notice: "Login Servers Down"
    end
  end

  def update
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to root_path, notice: "Login Servers Down"
    end
    if params[:user][:password] == ""
      Log.add_to_mongo_log("mongo", @user, "update", [first_name: params[:user][:first_name], last_name: params[:user][:last_name], username: params[:user][:username], phone: params[:user][:phone], email: params[:user][:email]])
      #@user.update(first_name: params[:user][:first_name], last_name: params[:user][:last_name], username: params[:user][:username], phone: params[:user][:phone], email: params[:user][:email])
    else
      Log.add_to_mongo_log("mongo", @user, "update", first_name: params[:user][:first_name], last_name: params[:user][:last_name], username: params[:user][:username], phone: params[:user][:phone], email: params[:user][:email], password: params[:user][:password])
      #@user.update(first_name: params[:user][:first_name], last_name: params[:user][:last_name], username: params[:user][:username], phone: params[:user][:phone], email: params[:user][:email], password: params[:user][:password])
    end
    redirect_to user_path
  end

  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :password, :phone, :email, :address, :city, :state, :zip, :credit_card, :cvv, :experation_date, :admin, :admin_password)
  end
end