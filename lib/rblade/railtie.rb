require "rails"
require "rblade/rails_template"
require "rblade/component_store"

module RBlade
  class Railtie < ::Rails::Railtie
    initializer :rblade, before: :load_config_initializers do |app|
      ActionView::Template.register_template_handler(:blade, RBlade::RailsTemplate.new)

      RBlade::ComponentStore
    end
  end
end
