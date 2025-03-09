require "test_case"
require "rblade/compiler"
require "rblade/component_store"
require "benchmark"

class BladeBenchmarkingTest < TestCase
  def setup
    super
  end

  def test_performance
    component_store = RBlade::ComponentStore.new
    compiled_string = RBlade::Compiler.compileString("<x-benchmark :colours/>", component_store)
    locals = "colours = [ { name: 'red',   current: false,  url: '#red', value: '#f00' }, { name: 'green', current: false, url: '#green', value: '#0f0' }, { name: 'blue',  current: false, url: '#blue', value: '#00f'  }, { name: 'yellow',  current: false, url: '#yellow', value: '#ff0'  }, { name: 'magenta',  current: false, url: '#magenta', value: '#f0f'  }, { name: 'cyan',  current: false, url: '#cyan', value: '#0ff'  }, { name: 'light red',   current: false,  url: '#light-red', value: '#f99' }, { name: 'light green', current: false, url: '#light-green', value: '#9f9' }, { name: 'light blue',  current: false, url: '#light-blue', value: '#99f'  }, { name: 'light yellow',  current: true, url: '#light-yellow', value: '#ff9'  }, { name: 'light magenta',  current: false, url: '#light-magenta', value: '#f9f'  }, { name: 'light cyan',  current: false, url: '#light-cyan', value: '#9ff'  }];"
    compiled_string = locals + component_store.get + "_stacks=[];@_rblade_once_tokens=[];" + compiled_string

    mod = Module.new do
      extend ActionView::Helpers

      @_rblade_stack_manager = RBlade::StackManager.new
      @output_buffer = ActionView::OutputBuffer.new
      @view_flow = ActionView::OutputFlow.new

      def self.params
        {email: "user@example.com"}
      end
    end

    # Benchmarking: set this to a higher number to test the performance of the compiler
    n = 1

    Benchmark.bmbm do |bm|
      bm.report("compile") { (1..n).each { RBlade::Compiler.compileString("benchmark", RBlade::ComponentStore.new) } }
      bm.report("execute") { (1..n).each { mod.module_eval(compiled_string) } }
    end
  end
end
