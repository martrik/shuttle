class RailwayClient
  API_ENDPOINT = "https://backboard.railway.com/graphql/v2"

  def initialize(api_token)
    @api_token = api_token
    @connection = Faraday.new(url: API_ENDPOINT) do |conn|
      conn.headers["Authorization"] = "Bearer #{@api_token}"
      conn.headers["Content-Type"] = "application/json"
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
    end
  end

  def fetch_projects
    query = <<~GRAPHQL
      query {
        projects {
          edges {
            node {
              id
              name
            }
          }
        }
      }
    GRAPHQL

    response = @connection.post do |req|
      req.body = { query: query }
    end

    if response.success? && response.body["data"]
      response.body["data"]["projects"]["edges"].map { |edge| edge["node"] }
    else
      []
    end
  end

  def create_service(project_id, docker_image, service_name = nil)
    service_name ||= "service-#{Time.now.to_i}"

    query = <<~GRAPHQL
      mutation serviceCreate($input: ServiceCreateInput!) {
        serviceCreate(input: $input) {
          id
          name
        }
      }
    GRAPHQL

    variables = {
      input: {
        projectId: project_id,
        name: service_name,
        source: {
          image: docker_image
        }
      }
    }

    response = @connection.post do |req|
      req.body = { query: query, variables: variables }
    end

    if response.success? && response.body["data"]
      response.body["data"]["serviceCreate"]
    else
      nil
    end
  end

  def delete_service(service_id)
    query = <<~GRAPHQL
      mutation serviceDelete($id: String!) {
        serviceDelete(id: $id)
      }
    GRAPHQL

    variables = { id: service_id }

    response = @connection.post do |req|
      req.body = { query: query, variables: variables }
    end

    response.success? && response.body["data"]
  end

  def restart_deployment(deployment_id)
    query = <<~GRAPHQL
      mutation deploymentRestart($id: String!) {
        deploymentRestart(id: $id)
      }
    GRAPHQL

    variables = { id: deployment_id }

    response = @connection.post do |req|
      req.body = { query: query, variables: variables }
    end

    response.success? && response.body["data"]
  end

  def fetch_service_details(service_id)
    query = <<~GRAPHQL
      query service($id: String!) {
        service(id: $id) {
          id
          name
          createdAt
          deployments {
            edges {
              node {
                id
                status
                url
                createdAt
              }
            }
          }
        }
      }
    GRAPHQL

    variables = { id: service_id }

    response = @connection.post do |req|
      req.body = { query: query, variables: variables }
    end

    if response.success? && response.body["data"]
      response.body["data"]["service"]
    else
      nil
    end
  end
end

