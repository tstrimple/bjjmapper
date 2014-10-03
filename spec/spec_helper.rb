# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'

SimpleCov.minimum_coverage 95
SimpleCov.maximum_coverage_drop 2
SimpleCov.start

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }


Mongoid.load!('./config/mongoid.yml')

Geocoder.configure(:lookup => :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'latitude'     => 40.7143528,
      'longitude'    => -74.0059731,
      'address'      => 'New York, NY, USA',
      'state'        => 'New York',
      'state_code'   => 'NY',
      'country'      => 'United States',
      'country_code' => 'US'
    }
  ]
)

OmniAuth.config.test_mode = true
omniauth_mock = {
  'provider' => 'twitter',
  'uid' => '12345',
  'info' => {
      'name' => 'twitteruser',
      'email' => 'hi@iamatwitteruser.com',
      'nickname' => 'SomeTwitterUser'
  }
}

OmniAuth.config.add_mock(:default, omniauth_mock)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.include FactoryGirl::Syntax::Methods

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.before do
    Mongoid.truncate!
    FactoryGirl.lint
  end
end
