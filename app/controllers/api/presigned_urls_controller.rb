# frozen_string_literal: true

module Api
  class PresignedUrlsController < ApplicationController
    def create
      app_name = params[:app_name]

      unless allowed_access_from?(app_name)
        render json: { error: "Access denied" }, status: :forbidden
        return
      end

      file_name = params[:file_name]
      content_type = params[:content_type]

      if file_name.blank? || content_type.blank?
        render json: { error: "file_name and content_type are required" }, status: :bad_request
        return
      end

      s3_client = Aws::S3::Client.new(
        region: Rails.application.credentials.dig(:aws, :region),
        access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
        secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
      )

      bucket_name = Rails.application.credentials.dig(:aws, :s3_bucket)
      object_key = "uploads/#{SecureRandom.uuid}/#{file_name}"

      begin
        presigner = Aws::S3::Presigner.new(client: s3_client)
        presigned_url = presigner.presigned_url(
          :put_object,
          bucket: bucket_name,
          key: object_key,
          content_type: content_type,
          expires_in: 3600 # 1 hour
        )

        render json: {
          url: presigned_url,
          key: object_key,
          expires_at: 1.hour.from_now
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error "Error generating presigned URL: #{e.message}"
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
