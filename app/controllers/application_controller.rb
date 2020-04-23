class ApplicationController < ActionController::Base
  before_action :is_authenticated
  def is_authenticated
    @current_user = User.find(session[:user_id]) rescue nil
    unless @current_user
      redirect_to new_session_path
      false
    end
    true
  end
end
