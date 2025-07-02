# frozen_string_literal: true

module Api
  class ImagesController < ApplicationController
    def show
      app_name = params[:app_name]

      unless allowed_access_from?(app_name)
        render json: { error: "Access denied" }, status: :forbidden
        return
      end

      object_key = params[:key]

      if object_key.blank?
        render json: { error: "Key parameter is required" }, status: :bad_request
        return
      end

      s3_client = Aws::S3::Client.new(
        region: Rails.application.credentials.dig(:aws, :region),
        access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
        secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
      )

      bucket_name = Rails.application.credentials.dig(:aws, :s3_bucket)

      begin
        presigner = Aws::S3::Presigner.new(client: s3_client)
        presigned_url = presigner.presigned_url(
          :get_object,
          bucket: bucket_name,
          key: object_key,
          expires_in: 3600 # 1 hour
        )

        render json: { url: presigned_url }, status: :ok
      rescue Aws::S3::Errors::NoSuchKey
        render json: { error: "Object not found" }, status: :not_found
      rescue StandardError => e
        Rails.logger.error "Error generating presigned URL: #{e.message}"
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
