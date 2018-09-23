require 'base64'
require 'typhoeus'
require 'oj'

require "finnegans/version"
require "finnegans/support"
require "finnegans/resource"
require "finnegans/client"

module Finnegans
  @@resources_namespace = ''
  @@api_catalog_path = ''

  DEFAULT_USER_AGENT = "Finnegans API Client v#{Finnegans::VERSION}".freeze
  private_constant :DEFAULT_USER_AGENT

  Typhoeus::Config.user_agent = DEFAULT_USER_AGENT

  class ArgumentError < StandardError; end
  class SetupError < StandardError; end

  class RequestError < StandardError
    # We are following Rubocop Style to declare them and raise them
    # https://github.com/rubocop-hq/ruby-style-guide#exception-class-messages
    attr_reader :content

    def initialize(content)
     super
     @content = content
    end
  end
  class AuthenticationError < RequestError; end

  class << self
    def api_catalog_path
      @@api_catalog_path
    end
    def resources_namespace
      @@resources_namespace
    end

    def setup
      yield self
    end

    def api_catalog_path=(value)
      value = value.to_s
      @@api_catalog_path = (value.empty? ? nil : value)
    end
    def resources_namespace=(value)
      value = value.to_s
      @@resources_namespace = (value.empty? ? nil : value)
    end
  end
end
