# frozen_string_literal: true

module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers_for(user)
    token = create(:oauth_access_token, resource_owner_id: user.id)
    {
      'Authorization' => "Bearer #{token.token}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def json_headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
