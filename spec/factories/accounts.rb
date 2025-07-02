# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    name { "Test Company #{SecureRandom.hex(4)}" }

    trait :with_users do
      after(:create) do |account|
        create_list(:user, 3, account: account)
      end
    end
  end
end
