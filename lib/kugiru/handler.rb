# frozen_string_literal: true

module Kugiru
  class Handler
    class_attribute :default_format
    self.default_format = :csv

    def self.call(template, source = nil)
      source ||= template.source

      <<~RUBY
        csv = ::Kugiru::Builder.new(utf8_bom: ::Kugiru.configuration.utf8_bom)
        #{source}
        response.headers['Cache-Control'] = 'no-cache'
        response.headers['X-Accel-Buffering'] = 'no'
        controller.send(:send_file_headers!, type: 'text/csv', filename: csv.filename)
        csv.build_enumerator
      RUBY
    end
  end
end
