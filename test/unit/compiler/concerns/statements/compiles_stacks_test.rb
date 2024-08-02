require "test_case"

class CompilesStacksTest < TestCase
  def test_stack
    assert_compiles_to "@stack('stack')",
      "RBlade::StackManager.initialize('stack', _out);_stacks.push('stack');_out = '';",
      ""
  end

  def test_prepends_come_before_pushes
    assert_compiles_to "@prepend('stack') 1 @endprepend @push('stack') 3 @endpush @stack('stack') @prepend('stack') 2 @endprepend @push('stack') 4 @endpush",
      nil,
      "1234"
  end

  def test_block_push
    assert_compiles_to "@push('stack') 12345 @endpush @stack('stack')", nil, "12345"
    assert_compiles_to "@stack('stack') @push('stack') 12345 @endpush", nil, "12345"
    assert_compiles_to "@stack('buttons') content @push('buttons')<x-button>hello</x-button>@endpush",
      nil,
      '<button class="button">hello</button>content'

    assert_compiles_to <<~BLADE
      @push('stack')
      1
      @push('stack')
      2
      @endpush
      @endpush
      @stack('stack')", nil, "12"
    BLADE
  end

  def test_block_prepend
    assert_compiles_to "@prepend('stack') 12345 @endprepend @stack('stack')", nil, "12345"
    assert_compiles_to "@stack('stack') @prepend('stack') 12345 @endprepend", nil, "12345"
    assert_compiles_to "@stack('buttons') content @prepend('buttons')<x-button>hello</x-button>@endprepend",
      nil,
      '<button class="button">hello</button>content'

    assert_compiles_to <<~BLADE
      @prepend('stack')
      1
      @prepend('stack')
      2
      @endprepend
      @endprepend
      @stack('stack')", nil, "12"
    BLADE
  end

  def test_component
    assert_compiles_to "@push('stack') 456 @endpush 123<x-compiles_stacks_test_stack/>789", nil, "123456789"
    assert_compiles_to "<x-compiles_stacks_test_stack/> @stack('other_stack')", nil, "123"
    assert_compiles_to "@stack('other_stack') <x-compiles_stacks_test_stack/>", nil, "123"
  end

  def test_limitations
    # We cannot push to a component stack after the component has been rendered
    assert_compiles_to "123<x-compiles_stacks_test_stack/>789 @push('stack') 456 @endpush", nil, "123789"

    # Stacks can only be output once
    assert_compiles_to "@push('stack') 123 @endpush @stack('stack') @stack('stack')", nil, "123"
  end
end
