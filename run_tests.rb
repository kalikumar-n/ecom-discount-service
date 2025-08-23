#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple test runner for the ecommerce discount service
require 'rspec/core'

puts "🧪 Running Ecommerce Discount Service Tests"
puts "=" * 50

# Configure RSpec
RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
end

# Run the tests
exit_code = RSpec::Core::Runner.run([
  'spec/entity/',
  'spec/enum/',
  'spec/exceptions/',
  'spec/discount_service_spec.rb',
  'spec/integration/'
])

puts "\n" + "=" * 50
if exit_code == 0
  puts "✅ All tests passed!"
else
  puts "❌ Some tests failed!"
end

exit exit_code 