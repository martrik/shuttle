class UsersController < ApplicationController
  def new
    redirect_to deployments_path if current_user
  end

  def create
    user = User.find_or_create_by!(railway_api_key: params[:railway_api_key])
    session[:user_id] = user.id
    redirect_to deployments_path, notice: "Welcome! You can now deploy to Railway."
  rescue StandardError => e
    redirect_to root_path, alert: "Failed to save API key: #{e.message}"
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
