require "test_helper"
require "minitest/mock"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_api_key = "valid_railway_key"
    @invalid_api_key = "invalid_key"
    @client_mock = Minitest::Mock.new
  end

  test "should create new user with unique api key" do
    RailwayClient.stub :new, @client_mock do
      @client_mock.expect :validate_token, { "id" => "user123" }

      assert_difference("User.count", 1) do
        post users_path, params: { railway_api_key: @valid_api_key }
      end

      assert_redirected_to deployments_path
      assert_equal @valid_api_key, User.last.railway_api_key
      @client_mock.verify
    end
  end

  test "should find existing user instead of creating duplicate" do
    existing_user = User.create!(railway_api_key: "existing_key")

    RailwayClient.stub :new, @client_mock do
      @client_mock.expect :validate_token, { "id" => "user123" }

      assert_no_difference("User.count") do
        post users_path, params: { railway_api_key: "existing_key" }
      end

      assert_redirected_to deployments_path
      assert_equal existing_user.id, session[:user_id]
      @client_mock.verify
    end
  end

  test "should set user_id in session after creation" do
    RailwayClient.stub :new, @client_mock do
      @client_mock.expect :validate_token, { "id" => "user123" }

      post users_path, params: { railway_api_key: "session_test_key" }
      assert_not_nil session[:user_id]
      assert_equal User.find_by(railway_api_key: "session_test_key").id, session[:user_id]
      @client_mock.verify
    end
  end

  test "should redirect with error when api key validation fails" do
    client_stub = Object.new
    def client_stub.validate_token
      raise StandardError.new("API error")
    end

    RailwayClient.stub :new, client_stub do
      assert_no_difference("User.count") do
        post users_path, params: { railway_api_key: @invalid_api_key }
      end

      assert_redirected_to root_path
      assert_equal "Invalid Railway API token. Please check your token and try again.", flash[:alert]
    end
  end

  test "should redirect with error when user creation fails" do
    RailwayClient.stub :new, @client_mock do
      @client_mock.expect :validate_token, { "id" => "user123" }

      User.stub :find_or_create_by!, ->(*args) { raise ActiveRecord::RecordInvalid.new } do
        assert_no_difference("User.count") do
          post users_path, params: { railway_api_key: @valid_api_key }
        end

        assert_redirected_to root_path
        assert_match(/Failed to save Railway API key/, flash[:alert])
      end
    end
  end
end
