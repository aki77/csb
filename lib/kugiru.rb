require 'kugiru/version'
require 'kugiru/railtie'
require 'kugiru/configuration'
require 'kugiru/builder'

module Kugiru
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
