require "rails"

module RBlade
  class Railtie < ::Rails::Railtie
    initializer :rblade, before: :load_config_initializers do |app|
      ActionView::Template.register_template_handler(:rblade, RailsTemplate.new)
    end
  end
end
