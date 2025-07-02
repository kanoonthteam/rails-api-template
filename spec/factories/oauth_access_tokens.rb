# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_access_token, class: 'Doorkeeper::AccessToken' do
    resource_owner_id { nil }
    association :application, factory: :oauth_application
    token { SecureRandom.hex(32) }
    expires_in { 2.hours }
    scopes { '' }
  end
end
