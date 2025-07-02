# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :accounts
    resources :users

    root to: "accounts#index"
  end

  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  devise_for :users, only: [ :passwords ]

  namespace :api do
    resources :users, only: [ :create ] do
      get :me, to: "users#show", on: :collection
    end

    resources :accounts, only: [ :index ]

    resources :images, only: [ :show ], param: :key, constraints: { key: /.*/ }
    resources :presigned_urls, only: [ :create ]
  end

  # Health check
  get "up" => "rails/health#show", :as => :rails_health_check
end
