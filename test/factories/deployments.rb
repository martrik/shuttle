FactoryBot.define do
  factory :deployment do
    association :user
    project_id { "proj_#{SecureRandom.hex(8)}" }
    service_id { "svc_#{SecureRandom.hex(8)}" }
    docker_image { "nginx:latest" }
    service_name { "deployment-#{Time.now.to_i}" }
    project_name { "Project #{rand(1..100)}" }
  end
end
