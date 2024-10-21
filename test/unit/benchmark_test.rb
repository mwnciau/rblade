require "test_case"
require "rblade/compiler"
require "rblade/component_store"

class BladeTemplatingTest < TestCase
  def setup
    super

    RBlade::ComponentStore.clear
  end

  def test_performance
    n = 50000
    compiled_string = RBlade::Compiler.compileString('<x-benchmark/>')
    Benchmark.bm do |bm|
      bm.report("compile") { for i in 1..n; RBlade::Compiler.compileString('benchmark'); end }
      bm.report("execute") { for i in 1..n; run_compiled_string(compiled_string); end }
    end
  end

  def run_compiled_string(compiled_string)
    locals ||= %(
      # frozen_string_literal: true
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
