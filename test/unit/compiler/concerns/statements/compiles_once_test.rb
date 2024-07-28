require "test_case"

class CompilesOnceTest < TestCase
  def test_once
    assert_compiles_to "@once hi @endonce", nil, "hi"
    assert_compiles_to "@once hi @endonce @once hi @endonce", nil, "hihi"
  end

  def test_once_keyed
    assert_compiles_to "@once('hi') hi @endonce", nil, "hi"
    assert_compiles_to "@once('hi') hi @endonce @once('hi') hi @endonce", nil, "hi"
    assert_compiles_to "@once('hi') hi @endonce @once('ho') ho @endonce", nil, "hiho"
    assert_compiles_to "@once('hi') hi @endonce @once(:hi) hi @endonce", nil, "hihi"
    assert_compiles_to "@once('hi') hi @endonce @once(:hi.to_s) hi @endonce", nil, "hi"
  end

  def test_once_component
    assert_compiles_to "<x-compiles_once_test.once/>", nil, "hi"

    assert_compiles_to "<x-compiles_once_test.once/><x-compiles_once_test.once/>",
      nil,
      "hi"
  end

  def test_push_once
    assert_compiles_to "@pushonce(:stack) hi @endpushonce", nil, ""
    assert_compiles_to "@pushonce(:stack) hi @endpushonce @stack(:stack)", nil, "hi"

    assert_compiles_to "@pushonce(:stack) hi @endpushonce @pushonce(:stack) hi @endonce @stack(:stack)",
      nil,
      "hihi"

    assert_compiles_to "@pushonce(:s1) hi @endpushonce @pushonce(:s2) hi @endonce @stack(:s1) @stack(:s2)",
      nil,
      "hihi"
  end

  def test_push_once_keyed
    assert_compiles_to "@pushonce(:stack, 'hi') hi @endpushonce @stack(:stack)",
      nil,
      "hi"

    assert_compiles_to "@pushonce(:stack, 'hi') hi @endpushonce @pushonce(:stack, 'hi') hi @endpushonce @stack(:stack)",
      nil,
      "hi"

    assert_compiles_to "@pushonce(:stack, 'hi') hi @endpushonce @pushonce(:stack, 'ho') ho @endpushonce @stack(:stack)",
      nil,
      "hiho"

    assert_compiles_to "@pushonce(:stack, 'hi') hi @endpushonce @pushonce(:stack, :hi) hi @endpushonce @stack(:stack)",
      nil,
      "hihi"

    assert_compiles_to "@pushonce(:stack, 'hi') hi @endpushonce @pushonce(:stack, :hi.to_s) hi @endpushonce @stack(:stack)",
      nil,
      "hi"
  end

  def test_push_once_component
    assert_compiles_to "<x-compiles_once_test.push_once/>@stack(:stack)", nil, "hi"

    assert_compiles_to "<x-compiles_once_test.push_once/><x-compiles_once_test.push_once/>@stack(:stack)",
      nil,
      "hi"
  end

  def test_prepend_once
    assert_compiles_to "@prependonce(:stack) hi @endprependonce", nil, ""
    assert_compiles_to "@prependonce(:stack) hi @endprependonce @stack(:stack)", nil, "hi"

    assert_compiles_to "@push(:stack) ho @endpush @prependonce(:stack) hi @endprependonce @stack(:stack)",
      nil,
      "hiho"

    assert_compiles_to "@prependonce(:stack) hi @endprependonce @prependonce(:stack) hi @endonce @stack(:stack)",
      nil,
      "hihi"

    assert_compiles_to "@prependonce(:s1) hi @endprependonce @prependonce(:s2) hi @endonce @stack(:s1) @stack(:s2)",
      nil,
      "hihi"
  end

  def test_prepend_once_keyed
    assert_compiles_to "@prependonce(:stack, 'hi') hi @endprependonce @stack(:stack)",
      nil,
      "hi"

    assert_compiles_to "@prependonce(:stack, 'hi') hi @endprependonce @prependonce(:stack, 'hi') hi @endprependonce @stack(:stack)",
      nil,
      "hi"

    assert_compiles_to "@prependonce(:stack, 'hi') hi @endprependonce @prependonce(:stack, 'ho') ho @endprependonce @stack(:stack)",
      nil,
      "hiho"

    assert_compiles_to "@prependonce(:stack, 'hi') hi @endprependonce @prependonce(:stack, :hi) hi @endprependonce @stack(:stack)",
      nil,
      "hihi"

    assert_compiles_to "@prependonce(:stack, 'hi') hi @endprependonce @prependonce(:stack, :hi.to_s) hi @endprependonce @stack(:stack)",
      nil,
      "hi"
  end

  def test_prepend_once_component
    assert_compiles_to "<x-compiles_once_test.prepend_once/>@stack(:stack)", nil, "hi"

    assert_compiles_to "<x-compiles_once_test.prepend_once/><x-compiles_once_test.prepend_once/>@stack(:stack)",
      nil,
      "hi"
  end
end
