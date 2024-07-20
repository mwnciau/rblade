require_relative "blade_compiler"

class ComponentStore
  def self.fetchComponent name
    if name == "button"
      return BladeCompiler.compileString '<button class="button">{{ slot }}</button>'
    end

    if name == "link"
      return BladeCompiler.compileString '<a href="{{ href }}">{{ slot }}</a>'
    end

    if name == "profile"
      return BladeCompiler.compileString '<div class="profile"><h2>{{ name.capitalize }}</h2>{{ slot }}<x-button>View</x-button></div>'
    end

    if name == "stack"
      BladeCompiler.compileString "@stack('stack') @push('other_stack', '123')"
    end
  end
end
