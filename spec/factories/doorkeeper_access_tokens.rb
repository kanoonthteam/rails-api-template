# frozen_string_literal: true

FactoryBot.define do
  factory :doorkeeper_access_token, class: "Doorkeeper::AccessToken" do
    association :resource_owner, factory: :user
    application { nil }
    expires_in { 7200 }
    scopes { "" }
  end
end
