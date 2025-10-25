FactoryBot.define do
  factory :user do
    railway_api_key { "test_railway_api_key_#{SecureRandom.hex(8)}" }
  end
end

