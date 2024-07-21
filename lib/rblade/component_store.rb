require "rblade/compiler"

module RBlade
  class ComponentStore
    def self.fetchComponent name
      if name == "button"
        return RBlade::Compiler.compileString '<button class="button">{{ slot }}</button>'
      end

      if name == "link"
        return RBlade::Compiler.compileString '<a href="{{ href }}">{{ slot }}</a>'
      end

      if name == "profile"
        return RBlade::Compiler.compileString '<div class="profile"><h2>{{ name.capitalize }}</h2>{{ slot }}<x-button>View</x-button></div>'
      end

      if name == "stack"
        RBlade::Compiler.compileString "@stack('stack') @push('other_stack', '123')"
      end
    end
  end
end
