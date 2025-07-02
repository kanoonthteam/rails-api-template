# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Images", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe "GET /api/images/:key" do
    let(:object_key) { "uploads/test/image.jpg" }
    let(:app_name) { "web" }

    before do
      # Mock AWS credentials
      allow(Rails.application.credentials).to receive(:dig).with(:aws, :region).and_return("us-east-1")
      allow(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return("test_key")
      allow(Rails.application.credentials).to receive(:dig).with(:aws, :secret_access_key).and_return("test_secret")
      allow(Rails.application.credentials).to receive(:dig).with(:aws, :s3_bucket).and_return("test-bucket")

      # Mock S3 client and presigner
      s3_client = instance_double(Aws::S3::Client)
      presigner = instance_double(Aws::S3::Presigner)

      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      allow(Aws::S3::Presigner).to receive(:new).and_return(presigner)
      allow(presigner).to receive(:presigned_url).and_return("https://example.com/presigned-url")
    end

    context "with valid parameters" do
      it "returns a presigned URL" do
        get "/api/images/#{object_key}", params: { app_name: app_name }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("url")
        expect(json_response["url"]).to eq("https://example.com/presigned-url")
      end
    end

    context "with invalid app_name" do
      it "returns forbidden status" do
        get "/api/images/#{object_key}", params: { app_name: "invalid_app" }, headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("Access denied")
      end
    end

    context "without app_name" do
      it "returns forbidden status" do
        get "/api/images/#{object_key}", headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("Access denied")
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        get "/api/images/#{object_key}", params: { app_name: app_name }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when object does not exist" do
      before do
        presigner = instance_double(Aws::S3::Presigner)
        allow(Aws::S3::Presigner).to receive(:new).and_return(presigner)
        allow(presigner).to receive(:presigned_url).and_raise(Aws::S3::Errors::NoSuchKey.new(nil, "key"))
      end

      it "returns not found status" do
        get "/api/images/#{object_key}", params: { app_name: app_name }, headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("Object not found")
      end
    end
  end
end
