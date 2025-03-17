# frozen_string_literal: true

require "rails"
require "rblade/rails_template"

module RBlade
  # Enables support for rendering RBlade components directly. This should be enabled if you want to use RBlade components within ERB or other templating languages.
  #
  # When enabled, attributes is set from local_assigns, the slot variable is set from the given block, and @props statements will look for content using content_for
  mattr_accessor :direct_component_rendering, default: false

  # The name of the view helper method used for rendering RBlade components in other templates
  mattr_accessor :component_helper_method_name, default: :component

  class Railtie < ::Rails::Railtie
    initializer :rblade, after: :load_config_initializers do |app|
      ActionView::Template.register_template_handler(:rblade, RBlade::RailsTemplate.new)
      setup_component_view_helper(ActionView::Helpers)

      RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "components"))
      RBlade::ComponentStore.add_path(Rails.root.join("app", "views", "layouts"), "layout")
      RBlade::ComponentStore.add_path(Rails.root.join("app", "views"), "view")
    end

    def setup_component_view_helper(mod)
      mod.send(:define_method, RBlade.component_helper_method_name) do |component_name, current_view = nil, **attributes, &block|
        # If this is a relative path, prepend with the previous component name's base
        if !current_view.nil? && component_name.start_with?(".")
          component_name = current_view.sub(/[^\.]++\z/, "") + component_name.delete_prefix(".")
        end

        path = RBlade::ComponentStore.find_component_file(component_name)

        # Find the relative template path without the file type
        view_paths.each do |view_path|
          break unless path.delete_prefix!(view_path.to_s).nil?
        end
        path.sub!(/(?:\.[^.]++)?\.rblade\z/, "")

        locals = {
          slot: block.nil? ? attributes.delete(:slot) || -"" : capture(&block),
          attributes: RBlade::AttributesManager.new(attributes)
        }

        render template: path, locals:
      end
    end
  end
end
