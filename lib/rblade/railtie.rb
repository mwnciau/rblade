# frozen_string_literal: true

require "rails"
require "rblade/rails_template"
require "rblade/component_store"

module RBlade
  class Railtie < ::Rails::Railtie
    initializer :rblade, before: :load_config_initializers do |app|
      ActionView::Template.register_template_handler(:rblade, RBlade::RailsTemplate.new)

      RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "components"))
      RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "layouts"), "layout")
      RBlade::ComponentStore.add_path(Rails.root.join("app", "views"), "view")
    end
  end
end
