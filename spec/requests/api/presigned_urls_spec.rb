# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::PresignedUrls", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe "POST /api/presigned_urls" do
    let(:valid_params) do
      {
        app_name: "web",
        file_name: "test-image.jpg",
        content_type: "image/jpeg"
      }
    end

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
      allow(presigner).to receive(:presigned_url).and_return("https://example.com/presigned-put-url")

      # Mock SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid).and_return("test-uuid")
    end

    context "with valid parameters" do
      it "returns a presigned URL with key and expiration" do
        post "/api/presigned_urls", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key("url")
        expect(json_response).to have_key("key")
        expect(json_response).to have_key("expires_at")
        expect(json_response["url"]).to eq("https://example.com/presigned-put-url")
        expect(json_response["key"]).to eq("uploads/test-uuid/test-image.jpg")
      end
    end

    context "with invalid app_name" do
      it "returns forbidden status" do
        invalid_params = valid_params.merge(app_name: "invalid_app")
        post "/api/presigned_urls", params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("Access denied")
      end
    end

    context "without app_name" do
      it "returns forbidden status" do
        invalid_params = valid_params.except(:app_name)
        post "/api/presigned_urls", params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("Access denied")
      end
    end

    context "without file_name" do
      it "returns bad request status" do
        invalid_params = valid_params.except(:file_name)
        post "/api/presigned_urls", params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("file_name and content_type are required")
      end
    end

    context "without content_type" do
      it "returns bad request status" do
        invalid_params = valid_params.except(:content_type)
        post "/api/presigned_urls", params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to eq("file_name and content_type are required")
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        post "/api/presigned_urls", params: valid_params.to_json, headers: json_headers

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when AWS error occurs" do
      before do
        presigner = instance_double(Aws::S3::Presigner)
        allow(Aws::S3::Presigner).to receive(:new).and_return(presigner)
        allow(presigner).to receive(:presigned_url).and_raise(StandardError.new("AWS Error"))
      end

      it "returns internal server error status" do
        post "/api/presigned_urls", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response["error"]).to eq("Internal server error")
      end
    end
  end
end
