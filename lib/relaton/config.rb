module Relaton
  module Config
    def configure
      if block_given?
        yield configuration
      end
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :logs, :use_api, :api_host

    def initialize
      @logs = %i(info error) # allowed values: :info, :warning, :error, :debug

      # @TODO change to true when we start using api.relaton.org
      @use_api = true
      @api_host = "https://api.relaton.org/api/v1"
    end
  end

  extend Config
end
