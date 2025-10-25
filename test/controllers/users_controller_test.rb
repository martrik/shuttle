require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should create new user with unique api key" do
    assert_difference("User.count", 1) do
      post users_path, params: { railway_api_key: "new_unique_key" }
    end
    assert_redirected_to deployments_path
    assert_equal "new_unique_key", User.last.railway_api_key
  end

  test "should find existing user instead of creating duplicate" do
    existing_user = User.create!(railway_api_key: "existing_key")

    assert_no_difference("User.count") do
      post users_path, params: { railway_api_key: "existing_key" }
    end

    assert_redirected_to deployments_path
    assert_equal existing_user.id, session[:user_id]
  end

  test "should set user_id in session after creation" do
    post users_path, params: { railway_api_key: "session_test_key" }
    assert_not_nil session[:user_id]
    assert_equal User.find_by(railway_api_key: "session_test_key").id, session[:user_id]
  end
end
