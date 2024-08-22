require 'rails/railtie'

module Csb
  class Railtie < Rails::Railtie
    initializer :csb do
      ActiveSupport.on_load :action_view do
        require 'csb/handler'
        ActionView::Template.register_template_handler :csb, Csb::Handler
      end
    end
  end
end
