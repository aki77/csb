require 'csb/version'
require 'csb/railtie'
require 'csb/configuration'
require 'csb/builder'

module Csb
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
