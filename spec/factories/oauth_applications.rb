# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { Faker::App.name }
    redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
    scopes { '' }
    confidential { false }
  end
end
