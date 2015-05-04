$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'warden/basic_auth'

require_relative 'helpers/rack_helpers'

RSpec.configure do |config|
  config.include RackHelpers
end
