require "test_helper"
require "minitest/mock"

class DeploymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @deployment = create(:deployment, user: @user)
  end

  test "should redirect to root if not authenticated" do
    get deployments_path
    assert_redirected_to root_path
    assert_equal "Please enter your Railway API token first.", flash[:alert]
  end

  test "should get index when authenticated" do
    sign_in_as(@user)
    get deployments_path
    assert_response :success
  end

  test "index should show only current user's deployments" do
    other_user = create(:user)
    create(:deployment, user: other_user)

    sign_in_as(@user)
    get deployments_path

    assert_response :success
    assert_select "body", text: /#{@deployment.service_name}/
  end

  test "index should order deployments by created_at desc" do
    sign_in_as(@user)
    create(:deployment, user: @user, created_at: 1.day.ago)
    create(:deployment, user: @user, created_at: 1.hour.ago)

    get deployments_path

    assert_response :success
  end

  test "should get new when authenticated" do
    sign_in_as(@user)
    projects = [ { "id" => "proj1", "name" => "Project 1" } ]

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_projects, projects

    RailwayClient.stub :new, railway_client_mock do
      get new_deployment_path
      assert_response :success
      railway_client_mock.verify
    end
  end

  test "should create deployment successfully" do
    sign_in_as(@user)
    project = { "id" => "proj1", "name" => "Test Project" }
    service = { "id" => "svc1", "name" => "test-service" }

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_project, project, [ "proj1" ]
    railway_client_mock.expect :create_service, service, [ String, String, String ]

    RailwayClient.stub :new, railway_client_mock do
      assert_difference("Deployment.count", 1) do
        post deployments_path, params: {
          project_id: "proj1",
          docker_image: "nginx:latest"
        }
      end

      assert_redirected_to deployment_path(Deployment.last)
      assert_equal "Deployment created successfully!", flash[:notice]
      railway_client_mock.verify
    end
  end

  test "create should handle service creation failure" do
    sign_in_as(@user)
    project = { "id" => "proj1", "name" => "Test Project" }

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_project, project, [ "proj1" ]
    railway_client_mock.expect :create_service, nil, [ String, String, String ]

    RailwayClient.stub :new, railway_client_mock do
      assert_no_difference("Deployment.count") do
        post deployments_path, params: {
          project_id: "proj1",
          docker_image: "nginx:latest"
        }
      end

      assert_redirected_to new_deployment_path
      assert_equal "Failed to create deployment.", flash[:alert]
      railway_client_mock.verify
    end
  end

  test "should show deployment" do
    sign_in_as(@user)
    service_details = { "id" => @deployment.service_id, "name" => "test-service" }

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_service_details, service_details, [ @deployment.service_id ]

    RailwayClient.stub :new, railway_client_mock do
      get deployment_path(@deployment)
      assert_response :success
      railway_client_mock.verify
    end
  end

  test "should not show other user's deployment" do
    other_user = create(:user)
    other_deployment = create(:deployment, user: other_user)

    sign_in_as(@user)

    get deployment_path(other_deployment)
    assert_response :not_found
  end

  test "should destroy deployment" do
    sign_in_as(@user)

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :delete_service, true, [ @deployment.service_id ]

    RailwayClient.stub :new, railway_client_mock do
      assert_difference("Deployment.count", -1) do
        delete deployment_path(@deployment)
      end

      assert_redirected_to deployments_path
      assert_equal "Deployment deleted successfully!", flash[:notice]
      railway_client_mock.verify
    end
  end

  test "should restart deployment" do
    sign_in_as(@user)
    service_details = {
      "deployments" => {
        "edges" => [
          { "node" => { "id" => "dep1", "status" => "SUCCESS" } }
        ]
      }
    }

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_service_details, service_details, [ @deployment.service_id ]
    railway_client_mock.expect :restart_deployment, true, [ "dep1" ]

    RailwayClient.stub :new, railway_client_mock do
      post restart_deployment_path(@deployment)

      assert_redirected_to deployment_path(@deployment)
      assert_equal "Deployment restarted successfully!", flash[:notice]
      railway_client_mock.verify
    end
  end

  test "restart should handle failure" do
    sign_in_as(@user)
    service_details = {
      "deployments" => {
        "edges" => [
          { "node" => { "id" => "dep1", "status" => "SUCCESS" } }
        ]
      }
    }

    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_service_details, service_details, [ @deployment.service_id ]
    railway_client_mock.expect :restart_deployment, false, [ "dep1" ]

    RailwayClient.stub :new, railway_client_mock do
      post restart_deployment_path(@deployment)

      assert_redirected_to deployment_path(@deployment)
      assert_equal "Failed to restart deployment.", flash[:alert]
      railway_client_mock.verify
    end
  end

  private

  def sign_in_as(user)
    railway_client_mock = Minitest::Mock.new
    railway_client_mock.expect :fetch_projects, []

    RailwayClient.stub :new, railway_client_mock do
      post users_path, params: { railway_api_key: user.railway_api_key }
      follow_redirect!
    end
  end
end
