class UsersController < ApplicationController
  def new
    redirect_to deployments_path if current_user
  end

  def create
    begin
      check_valid_api_key!
    rescue StandardError => e
      puts "Error: #{e.message}"
      return redirect_to root_path, alert: "Invalid Railway API token. Please check your token and try again."
    end

    user = User.find_or_create_by!(railway_api_key: create_params)
    session[:user_id] = user.id
    redirect_to deployments_path, notice: "Welcome! You can now deploy to Railway."
  rescue StandardError => e
    redirect_to root_path, alert: "Failed to save Railway API key: #{e.message}"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "You have been logged out."
  end

  private

  def create_params
    params.require(:railway_api_key)
  end

  def check_valid_api_key!
    client = RailwayClient.new(create_params)
    client.validate_token
  end
end
