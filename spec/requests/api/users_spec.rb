# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Users", type: :request do
  describe "POST /api/users" do
    let(:valid_params) do
      {
        email: "newuser@example.com",
        password: "password123",
        name: "New User",
        phone_number: "+12125551234"
      }
    end

    context "with valid params" do
      it "creates a new user" do
        expect {
          post api_users_path, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "returns errors" do
        post api_users_path, params: valid_params.merge(email: "invalid_email")

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /api/users/me" do
    let(:user) { create(:user) }
    let(:token) { create(:doorkeeper_access_token, resource_owner_id: user.id) }

    context "with valid token" do
      it "returns current user" do
        get me_api_users_path, headers: { "Authorization" => "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "without token" do
      it "returns unauthorized" do
        get me_api_users_path

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
