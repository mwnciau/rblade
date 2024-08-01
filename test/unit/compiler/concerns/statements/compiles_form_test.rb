require "test_case"

class CompilesHelpersTest < TestCase
  def test_method
    assert_compiles_to "@method('POST')", nil, '<input type="hidden" name="_method" value="POST">'
    assert_compiles_to '@method("GET")', nil, '<input type="hidden" name="_method" value="GET">'
    assert_compiles_to "@method('PUT')", nil, '<input type="hidden" name="_method" value="PUT">'
  end

  def test_delete
    assert_compiles_to "@delete", nil, '<input type="hidden" name="_method" value="DELETE">'
  end

  def test_patch
    assert_compiles_to "@patch", nil, '<input type="hidden" name="_method" value="PATCH">'
  end

  def test_put
    assert_compiles_to "@put", nil, '<input type="hidden" name="_method" value="PUT">'
  end

  def test_old
    assert_compiles_to "@old(:email)", nil, 'user@example.com'
    assert_compiles_to "@old(:email, 'default')", nil, 'user@example.com'

    assert_compiles_to "@old(:not_a_field)", nil, ''
    assert_compiles_to "@old(:not_a_field, 'default')", nil, 'default'
  end
end
