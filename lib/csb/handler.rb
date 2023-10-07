# frozen_string_literal: true

require 'csb/template'
require 'csb/errors'

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
        )
        #{source}
        controller.send(:send_file_headers!, type: 'text/csv', filename: csv.filename)
        if csv.streaming?
          unless controller.respond_to?(:send_stream)
            raise ::Csb::ActionControllerLiveNotIncludedError.new(controller)
          end

          controller.send_stream(filename: csv.filename, type: 'text/csv') do |stream|
            csv.build.each { |row| stream.write(row) }
          end
        else
          csv.build
        end
      RUBY
    end
  end
end
