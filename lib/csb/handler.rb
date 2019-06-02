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
        )
        #{source}
        controller.send(:send_file_headers!, type: 'text/csv', filename: csv.filename)
        if csv.streaming
          response.headers['Cache-Control'] = 'no-cache'
          response.headers['X-Accel-Buffering'] = 'no'
          csv.build_enumerator
        else
          csv.build_string
        end
      RUBY
    end
  end
end
