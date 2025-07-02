source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "aasm"
gem "administrate"
gem "aws-sdk-s3", "~> 1"
gem "devise"
gem "doorkeeper"
gem "jsonapi-rails", "~> 0.4.0"
gem "pg", "~> 1.1"
gem "pg_search"
gem "puma", ">= 5.0"
gem "pundit", "~> 2.5"
gem "rack-cors"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "twilio-ruby"
gem "phony_rails"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "dockerfile-rails", ">= 1.6"
end

group :test do
  gem "simplecov", require: false
  gem "webmock"
  gem "vcr"
end
