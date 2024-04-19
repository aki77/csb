require 'rails/railtie'

module Csb
  class Railtie < Rails::Railtie
    initializer :csb do
      ActiveSupport.on_load :action_view do
        require 'csb/handler'
        ActionView::Template.register_template_handler :csb, Csb::Handler

        # SEE: https://github.com/rails/rails/pull/51023
        rails_version = Gem::Version.new(Rails.version)
        if rails_version >= Gem::Version.new('7.1.0') && rails_version < Gem::Version.new('7.1.4')
          ActionView::Template.prepend(Module.new do
            # SEE: https://github.com/Shopify/rails/blob/0601929486398954a17b1985fcf7f9f0611d2d55/actionview/lib/action_view/template.rb#L262C5-L281C8
            def render(view, locals, buffer = nil, implicit_locals: [], add_to_stack: true, &block)
              instrument_render_template do
                compile!(view)

                if strict_locals? && @strict_local_keys && !implicit_locals.empty?
                  locals_to_ignore = implicit_locals - @strict_local_keys
                  locals.except!(*locals_to_ignore)
                end

                if buffer
                  view._run(method_name, self, locals, buffer, add_to_stack: add_to_stack, has_strict_locals: strict_locals?, &block)
                  nil
                else
                  result = view._run(method_name, self, locals, ActionView::OutputBuffer.new, add_to_stack: add_to_stack, has_strict_locals: strict_locals?, &block)
                  result.is_a?(ActionView::OutputBuffer) ? result.to_s : result
                end
              end
            rescue => e
              handle_render_error(view, e)
            end
          end)
        end
      end
    end
  end
end
