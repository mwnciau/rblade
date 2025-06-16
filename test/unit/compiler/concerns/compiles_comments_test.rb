require "test_case"

class CompilesCommentsTest < TestCase
  def test_comments
    assert_compiles_to "{{--this is a comment--}}", "", ""
    assert_compiles_to "{{--
    this is a comment
    --}}", "", ""
    assert_compiles_to "{{-- this is a #{"very " * 1000} long comment --}}", "", ""
  end

  def test_erb_style
    assert_compiles_to "<%#this is a comment%>", "", ""
    assert_compiles_to "<%#
    this is a comment
    %>", "", ""
    assert_compiles_to "<%# this is a #{"very " * 1000} long comment %>", "", ""
  end

  def test_code_inside_comments
    assert_compiles_to "{{-- {{ myvar }} --}}", "", ""
  end

  def test_comments_token_offsets
    assert_tokens "{{--comment--}}", []
    assert_tokens "abc {{--comment--}} def", [
      {type: :unprocessed, start_offset: 0, end_offset: 8},
    ]

    assert_tokens "<%#comment%>", []
    assert_tokens "abc <%#comment%> def", [
      {type: :unprocessed, start_offset: 0, end_offset: 8},
    ]

    assert_tokens <<~RBLADE.strip, []
      {{--
      comment
      --}}
    RBLADE
    source = <<~RBLADE.strip
      abc
      {{--
      comment
      --}}
      def
    RBLADE
    assert_tokens source, [
      {type: :unprocessed, start_offset: 0, end_offset: 8},
    ]
  end

  def test_comments_source_offsets
    assert_comment_sources_offsets("{{-- comment --}}", [{source_position: 0, offset: 17}])
    assert_comment_sources_offsets("abc{{-- comment --}}def", [{source_position: 3, offset: 17}])
    assert_comment_sources_offsets(<<~RBLADE.strip, [{source_position: 3, offset: 17}])
      abc{{--
      comment
      --}}def
    RBLADE

    assert_comment_sources_offsets("a{{-- --}}b{{-- --}}c{{-- --}}d", [
      {source_position: 1, offset: 9},
      {source_position: 2, offset: 9},
      {source_position: 3, offset: 9},
    ])
  end

  private def assert_comment_sources_offsets(code, expected_offsets)
    offsets = RBlade::CompilesComments.comment_offsets(code)

    assert_equal expected_offsets, offsets
  end
end
