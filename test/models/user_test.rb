require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "railway_api_key must be present" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:railway_api_key], "can't be blank"
  end

  test "railway_api_key must be unique" do
    User.create!(railway_api_key: "unique_key")
    duplicate_user = User.new(railway_api_key: "unique_key")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:railway_api_key], "has already been taken"
  end

  test "users can have different railway_api_keys" do
    User.create!(railway_api_key: "key_1")
    user2 = User.new(railway_api_key: "key_2")
    assert user2.valid?
  end
end
