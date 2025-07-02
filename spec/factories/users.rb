# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    name { "Test User" }
    phone_number { "+12125551234" }
    role { "employee" }
    association :account

    trait :admin do
      role { "admin" }
    end

    trait :owner do
      role { "owner" }
    end

    trait :without_account do
      account { nil }
    end
  end
end