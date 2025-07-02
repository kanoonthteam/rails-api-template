# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    skip_before_action :doorkeeper_authorize!, only: [ :create ]

    def show
      render jsonapi: current_user
    end

    def create
      user = User.new(user_params)

      if user.save
        render jsonapi: user, status: :created
      else
        render jsonapi_errors: user.errors, status: :unprocessable_entity
      end
    end

    def update
      if current_user.update(user_params)
        render jsonapi: current_user
      else
        render jsonapi_errors: current_user.errors, status: :unprocessable_entity
      end
    end

    private

    def user_params
      # Remove account_id from permitted params to prevent users from assigning themselves to any account
      params.permit(:email, :password, :name, :phone_number)
    end
  end
end
