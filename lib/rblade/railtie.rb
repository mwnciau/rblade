# frozen_string_literal: true

require "rails"
require "rblade/rails_template"
require "rblade/component_store"

module RBlade
  # Enables support for rendering RBlade components directly. This should be enabled if you want to use RBlade components within ERB or other templating languages.
  #
  # When enabled, attributes is set from local_assigns, the slot variable is set from the given block, and @props statements will look for content using content_for
  mattr_accessor :direct_component_rendering, default: false

  class Railtie < ::Rails::Railtie
    initializer :rblade, before: :load_config_initializers do |app|
      ActionView::Template.register_template_handler(:rblade, RBlade::RailsTemplate.new)

      RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "components"))
      RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "layouts"), "layout")
      RBlade::ComponentStore.add_path(Rails.root.join("app", "views"), "view")
    end
  end
end
