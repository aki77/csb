# frozen_string_literal: true

require 'csb/template'

module Csb
  class Handler
    class_attribute :default_format
    self.default_format = :csv

    def self.call(template, source = nil)
      source ||= template.source

      <<~RUBY
        csv = ::Csb::Template.new(
          utf8_bom: ::Csb.configuration.utf8_bom,
          streaming: ::Csb.configuration.streaming,
          csv_options: ::Csb.configuration.csv_options,
        )
        #{source}
        controller.send(:send_file_headers!, type: 'text/csv', filename: csv.filename)
        if csv.streaming?
          response.headers['Cache-Control'] = 'no-cache'
          response.headers['X-Accel-Buffering'] = 'no'
          # SEE: https://github.com/rack/rack/issues/1619
          if Gem::Version.new('2.2.0') <= Gem::Version.new(Rack::RELEASE)
            response.headers['Last-Modified'] = '0'
          end
        end
        csv.build
      RUBY
    end
  end
end
