# frozen_string_literal: true

module Api
  class AccountsController < ApplicationController
    def show
      render jsonapi: current_account
    end

    def update
      if current_account.update(account_params)
        render jsonapi: current_account
      else
        render jsonapi_errors: current_account.errors, status: :unprocessable_entity
      end
    end

    private

    def account_params
      params.permit(:name)
    end
  end
end
