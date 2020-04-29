class ApplicationController < ActionController::Base
  before_action :set_current_user, :is_authenticated

  def is_authenticated
    unless @current_user
      redirect_to new_sessions_path
      false
    end
    true
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) rescue nil
  end
end
