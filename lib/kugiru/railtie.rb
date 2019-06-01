require 'rails/railtie'

module Kugiru
  class Railtie < Rails::Railtie
    initializer :kugiru do
      ActiveSupport.on_load :action_view do
        require 'kugiru/handler'
        ActionView::Template.register_template_handler :cb, Kugiru::Handler
      end
    end
  end
end
