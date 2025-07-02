# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize!

  CLIENT_APP_NAMES = %w[
    ios
    android
    web
  ].freeze

  private

  def current_user
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_account
    current_user&.account
  end

  def allowed_access_from?(app_name)
    CLIENT_APP_NAMES.include?(app_name)
  end
end
