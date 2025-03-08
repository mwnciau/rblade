require "test_case"
require "rblade/compiler"
require "rblade/component_store"
require "benchmark"

class BladeBenchmarkingTest < TestCase
  def setup
    super
  end

  def test_performance
    # Benchmarking: set this to a higher number to test the performance of the compiler
    n = 1
    compiled_string = RBlade::Compiler.compileString("<x-benchmark/>", RBlade::ComponentStore.new)
    Benchmark.bmbm do |bm|
      bm.report("compile") { (1..n).each { RBlade::Compiler.compileString("benchmark", RBlade::ComponentStore.new) } }
      bm.report("execute") { (1..n).each { run_compiled_string(compiled_string) } }
    end
  end

  def run_compiled_string(compiled_string)
    locals ||= %(
      extend ActionView::Helpers;
      foo = "FOO";
      bar = "BAR";
      params = {email: "user@example.com"};
      session = {user_id: 4};
      flash = {notice: "Request successful"};
      cookies = {accept_cookies: true};
    )
    Class.new.instance_eval locals + RBlade::RailsTemplate.new.call(nil, compiled_string)
  end
end
