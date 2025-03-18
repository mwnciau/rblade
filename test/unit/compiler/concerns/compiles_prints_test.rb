require "test_case"

class CompilesPrintsTest < TestCase
  def test_variable
    assert_compiles_to "{{foo}}", "@output_buffer.append=foo;", "FOO"
    assert_compiles_to "{{ foo }}", "@output_buffer.append=foo;", "FOO"
    assert_compiles_to "{{
      foo
      }}", "@output_buffer.append=foo;", "FOO"

    assert_compiles_to "{!!foo!!}", "@output_buffer.raw_buffer<<(foo).to_s;", "FOO"
    assert_compiles_to "{!! foo !!}", "@output_buffer.raw_buffer<<(foo).to_s;", "FOO"
    assert_compiles_to "{!!
      foo
      !!}", "@output_buffer.raw_buffer<<(foo).to_s;", "FOO"
  end

  def test_string
    assert_compiles_to "{{ 'foo' }}", "@output_buffer.append='foo';", "foo"
    assert_compiles_to "{{ 1 }}", "@output_buffer.append=1;", "1"
    assert_compiles_to "{{ 'hello dear reader' }}", "@output_buffer.append='hello dear reader';", "hello dear reader"

    assert_compiles_to "{!! 'foo' !!}", "@output_buffer.raw_buffer<<('foo').to_s;", "foo"
    assert_compiles_to "{!! 1 !!}", "@output_buffer.raw_buffer<<(1).to_s;", "1"
    assert_compiles_to "{!! 'hello dear reader' !!}", "@output_buffer.raw_buffer<<('hello dear reader').to_s;", "hello dear reader"
  end

  def test_expression
    assert_compiles_to "{{ foo + bar << 'BAZ' }}", "@output_buffer.append=foo + bar << 'BAZ';", "FOOBARBAZ"
    assert_compiles_to %q({{ "foo" + 'bar' }}), %q(@output_buffer.append="foo" + 'bar';), "foobar"
    assert_compiles_to '{{ "#{foo}" }}', '@output_buffer.append="#{foo}";', "FOO" # rubocop:disable Lint/InterpolationCheck
    assert_compiles_to "{{ 'a' * 3 }}", "@output_buffer.append='a' * 3;", "aaa"

    assert_compiles_to "{!! foo + bar << 'BAZ' !!}", "@output_buffer.raw_buffer<<(foo + bar << 'BAZ').to_s;", "FOOBARBAZ"
    assert_compiles_to %q({!! "foo" + 'bar' !!}), %q[@output_buffer.raw_buffer<<("foo" + 'bar').to_s;], "foobar"
    assert_compiles_to '{!! "#{foo}" !!}', '@output_buffer.raw_buffer<<("#{foo}").to_s;', "FOO" # rubocop:disable Lint/InterpolationCheck
    assert_compiles_to "{!! 'a' * 3 !!}", "@output_buffer.raw_buffer<<('a' * 3).to_s;", "aaa"
  end

  def test_multiple
    assert_compiles_to "{{'foo'}}bar", "@output_buffer.append='foo';@output_buffer.raw_buffer<<-'bar';", "foobar"
    assert_compiles_to "foo{{'bar'}}", "@output_buffer.raw_buffer<<-'foo';@output_buffer.append='bar';", "foobar"
    assert_compiles_to "foo{{
    'bar'
    }}baz", "@output_buffer.raw_buffer<<-'foo';@output_buffer.append='bar';@output_buffer.raw_buffer<<-'baz';", "foobarbaz"

    assert_compiles_to "{!!'foo'!!}bar", "@output_buffer.raw_buffer<<('foo').to_s;@output_buffer.raw_buffer<<-'bar';", "foobar"
    assert_compiles_to "foo{!!'bar'!!}", "@output_buffer.raw_buffer<<-'foo';@output_buffer.raw_buffer<<('bar').to_s;", "foobar"
    assert_compiles_to "foo{!!
    'bar'
    !!}baz", "@output_buffer.raw_buffer<<-'foo';@output_buffer.raw_buffer<<('bar').to_s;@output_buffer.raw_buffer<<-'baz';", "foobarbaz"
  end

  def test_escaped
    assert_compiles_to "@{{foo}}", "@output_buffer.raw_buffer<<-'{{foo}}';", "{{foo}}"
    assert_compiles_to "@{{ foo }}", "@output_buffer.raw_buffer<<-'{{ foo }}';", "{{ foo }}"
    assert_compiles_to "@{{
      foo
      }}", "@output_buffer.raw_buffer<<-'{{
      foo
      }}';", "{{
      foo
      }}"

    assert_compiles_to "@{!!foo!!}", "@output_buffer.raw_buffer<<-'{!!foo!!}';", "{!!foo!!}"
    assert_compiles_to "@{!! foo !!}", "@output_buffer.raw_buffer<<-'{!! foo !!}';", "{!! foo !!}"
    assert_compiles_to "@{!!
        foo
        !!}", "@output_buffer.raw_buffer<<-'{!!
        foo
        !!}';", "{!!
        foo
        !!}"

    assert_compiles_to "<%%=foo%>", "@output_buffer.raw_buffer<<-'<%=foo%>';", "<%=foo%>"
    assert_compiles_to "<%%= foo %>", "@output_buffer.raw_buffer<<-'<%= foo %>';", "<%= foo %>"
    assert_compiles_to "<%%=
      foo
      %>", "@output_buffer.raw_buffer<<-'<%=
      foo
      %>';", "<%=
      foo
      %>"

    assert_compiles_to "<%%==foo%>", "@output_buffer.raw_buffer<<-'<%==foo%>';", "<%==foo%>"
    assert_compiles_to "<%%== foo %>", "@output_buffer.raw_buffer<<-'<%== foo %>';", "<%== foo %>"
    assert_compiles_to "<%%==
      foo
      %>", "@output_buffer.raw_buffer<<-'<%==
      foo
      %>';", "<%==
      foo
      %>"
  end

  def test_dangerous_strings
    assert_compiles_to %q({{ '"\'\\\\\\'' }}), %q(@output_buffer.append='"\'\\\\\\'';), "&quot;&#39;\\&#39;"
    assert_compiles_to %q({{ '<&"\'>' }}), %q(@output_buffer.append='<&"\'>';), "&lt;&amp;&quot;&#39;&gt;"
    assert_compiles_to %q(@{{ '"\'\\\\\\'' }}), nil, %q({{ '"\\'\\\\\\'' }})

    assert_compiles_to %q({!! '"\'\\\\\\'' !!}), %q[@output_buffer.raw_buffer<<('"\'\\\\\\'').to_s;], %q("'\\')
    assert_compiles_to %q({!! '<&"\'>' !!}), %q[@output_buffer.raw_buffer<<('<&"\'>').to_s;], "<&\"'>"
  end

  def test_erb_style
    assert_compiles_to "<%=foo%>", "@output_buffer.append=foo;", "FOO"
    assert_compiles_to "<%= foo %>", "@output_buffer.append=foo;", "FOO"
    assert_compiles_to "<%=
      foo
      %>", "@output_buffer.append=foo;", "FOO"

    assert_compiles_to "<%==foo%>", "@output_buffer.raw_buffer<<(foo).to_s;", "FOO"
    assert_compiles_to "<%== foo %>", "@output_buffer.raw_buffer<<(foo).to_s;", "FOO"
    assert_compiles_to "<%==
      foo
      %>", "@output_buffer.raw_buffer<<(foo).to_s;", "FOO"
  end

  def test_limitations
    # The end tag cannot appear within the print
    assert_compiles_to "{{ 'foo}}' }}", "@output_buffer.append='foo;@output_buffer.raw_buffer<<-'\\' }}';"
    assert_compiles_to "<%= 'foo%>' %>", "@output_buffer.append='foo;@output_buffer.raw_buffer<<-'\\' %>';"

    # A workaround to this is using the alternative syntax
    assert_compiles_to "<%= 'foo}}' %>", "@output_buffer.append='foo}}';", "foo}}"
    assert_compiles_to "{{ 'foo%>' }}", "@output_buffer.append='foo%>';", "foo%&gt;"
  end

  def test_raw
    assert_compiles_to "{{ '<>' }}", "@output_buffer.append='<>';", "&lt;&gt;"
    assert_compiles_to "{{ raw('<>') }}", "@output_buffer.append=raw('<>');", "<>"

    assert_compiles_to "{{ '\"\\'' }}", nil, "&quot;&#39;"
    assert_compiles_to "{{ raw('\"\\'') }}", nil, "\"'"
  end

  def test_printing_member_variables
    assert_compiles_to "{{ @foo }}", "@output_buffer.append=@foo;"
  end

  def test_block_helpers
    block_helper_funcs = %[<%
      def self.block_helper_func(&)
        output = +"2"
        output << capture(&)
        output << "4"
      end

      def self.block_helper_func_with_arg(&)
        output = +"2"
        output << capture("3", &)
        output << "4"
      end
    %>]

    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func do }}3{{ end }}5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func { }}3{{ } }}5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func_with_arg do |x| }}{{ x }}{{ end }}5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func_with_arg { |x| }}{{ x }}{{ } }}5", nil, "12345"

    assert_compiles_to "1{{ content_for :block do }}<b>3</b>{{ end }}2{{ content_for :block }}", nil, "12<b>3</b>"
    assert_compiles_to "1<% content_for :block do %><b>3</b><% end %>2<%= content_for :block %>", nil, "12<b>3</b>"
    assert_compiles_to "1<%= content_for :block do %><b>3</b><%= end %>2<%= content_for :block %>", nil, "12<b>3</b>"
    assert_compiles_to "1<%== content_for :block do %><b>3</b><%== end %>2<%= content_for :block %>", nil, "12<b>3</b>"

    # Test that if statements on the end block work
    assert_compiles_to "1{{ content_for :block do }}<b>3</b>{{ end if true }}2{{ content_for :block }}", nil, "12<b>3</b>"
    assert_compiles_to "1{{ content_for :block do }}<b>3</b>{{ end if false }}2{{ content_for :block }}", nil, "12"

    # Ensure return value is properly set
    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func_with_arg do |x| }}3<% x = 'bad' %>{{ end }}5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func_with_arg do |x| }}3 @ruby(x = 'bad'){{ end }}5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1{{ block_helper_func_with_arg do |x| }}<%= x %><% x = 'bad' %>{{ end }}5", nil, "12345"

    # Ensure this still works when we wrap the end block differently
    assert_compiles_to "#{block_helper_funcs}1<%= block_helper_func do %>3<% end %>5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1<%= block_helper_func { %>3<% } %>5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1<%= block_helper_func do %>3 @ruby(end)5", nil, "12345"
    assert_compiles_to "#{block_helper_funcs}1<%= block_helper_func do %>3<% x = 'bad' %><% end %>5", nil, "12345"
  end
end
