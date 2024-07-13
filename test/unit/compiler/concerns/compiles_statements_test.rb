require_relative "../../../test_case"
require_relative "../../../../lib/compiler/blade_compiler"

class EchoTest < TestCase
  def test_end
    assert_compiles_to "@end", "end;"
  end

  def test_fails_with_wrong_arguments
    exception = assert_raises Exception do
      BladeCompiler.compileString("@not_a_real_statement")
    end
    assert_equal "Unhandled statement: @not_a_real_statement", exception.to_s
  end
end
