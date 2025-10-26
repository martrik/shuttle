class DeploymentsController < ApplicationController
  before_action :authenticate_user
  before_action :set_deployment, only: [ :show, :destroy, :restart ]

  def index
    @deployments = current_user.deployments.order(created_at: :desc)
  end

  def new
    @railway_client = RailwayClient.new(current_user.railway_api_key)
    @projects = @railway_client.fetch_projects
  rescue StandardError => e
    redirect_to root_path, alert: "Failed to fetch projects: #{e.message}"
  end

  def create
    railway_client = RailwayClient.new(current_user.railway_api_key)
    project = railway_client.fetch_project(params[:project_id])

    service = railway_client.create_service(
      params[:project_id],
      params[:docker_image],
      "deployment-#{Time.now.to_i}"
    )

    if service
      deployment = current_user.deployments.create!(
        project_id: params[:project_id],
        service_id: service["id"],
        docker_image: params[:docker_image],
        service_name: service["name"],
        project_name: project["name"]
      )
      redirect_to deployment_path(deployment), notice: "Deployment created successfully!"
    else
      redirect_to new_deployment_path, alert: "Failed to create deployment."
    end
  rescue StandardError => e
    redirect_to new_deployment_path, alert: "Failed to create deployment: #{e.message}"
  end

  def show
    @railway_client = RailwayClient.new(current_user.railway_api_key)
    @service_details = @railway_client.fetch_service_details(@deployment.service_id)
  rescue StandardError => e
    flash.now[:alert] = "Failed to fetch deployment details: #{e.message}"
  end

  def destroy
    railway_client = RailwayClient.new(current_user.railway_api_key)
    railway_client.delete_service(@deployment.service_id)
    @deployment.destroy
    redirect_to deployments_path, notice: "Deployment deleted successfully!"
  rescue StandardError => e
    redirect_to deployment_path(@deployment), alert: "Failed to delete deployment: #{e.message}"
  end

  def restart
    railway_client = RailwayClient.new(current_user.railway_api_key)

    service_details = railway_client.fetch_service_details(@deployment.service_id)
    latest_deployment = service_details&.dig("deployments", "edges")&.first&.dig("node")

    if latest_deployment && railway_client.restart_deployment(latest_deployment["id"])
      redirect_to deployment_path(@deployment), notice: "Deployment restarted successfully!"
    else
      redirect_to deployment_path(@deployment), alert: "Failed to restart deployment."
    end
  rescue StandardError => e
    redirect_to deployment_path(@deployment), alert: "Failed to restart deployment: #{e.message}"
  end

  private

  def authenticate_user
    unless current_user
      redirect_to root_path, alert: "Please enter your Railway API token first."
    end
  end

  def set_deployment
    @deployment = current_user.deployments.find(params[:id])
  end
end
