# frozen_string_literal: true

module Csb
  class Handler
    class_attribute :default_format
    self.default_format = :csv

    def self.call(template, source = nil)
      source ||= template.source

      <<~RUBY
        csv = OpenStruct.new(
          utf8_bom: ::Csb.configuration.utf8_bom,
          streaming: ::Csb.configuration.streaming,
          cols: {},
          data: []
        )
        #{source}
        controller.send(:send_file_headers!, type: 'text/csv', filename: csv.filename)
        _builder_args = csv.to_h.slice(:utf8_bom, :cols, :data)
        if csv.streaming
          response.headers['Cache-Control'] = 'no-cache'
          response.headers['X-Accel-Buffering'] = 'no'
          ::Csb::Builder.build_enumerator(_builder_args)
        else
          ::Csb::Builder.build(_builder_args)
        end
      RUBY
    end
  end
end
