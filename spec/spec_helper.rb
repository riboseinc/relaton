# frozen_string_literal: true

require "bundler/setup"
require "fileutils"
require "rspec/matchers"
require "equivalent-xml"
require "simplecov"
require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr_cassetes"
  c.default_cassette_options = {
    clean_outdated_http_interactions: true,
    re_record_interval: 7 * 24 * 3600,
    record: :once,
  }
  c.hook_into :webmock
end

SimpleCov.start do
  add_filter "/spec/"
end

require "relaton"

Relaton.configure do |config|
  config.use_api = false
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
