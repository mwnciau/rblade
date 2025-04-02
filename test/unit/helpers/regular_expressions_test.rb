require "test_case"
require "rblade/helpers/regular_expressions"

class RegularExpressionsTest < TestCase
  def test_ruby_regex
    # rubocop:disable Lint/NestedPercentLiteral
    matched_strings = %w[
      "abcd"
      "ab\
cd"
      'abcd'
      'ab\
cd'
      "\""
      '\''
      '#{'
      "a#{bc}d"
      "a#{b\
c}d"
      "a#{"bc"}d"
      "a#d"
      "a#{"b}c"}d"
      "a#{"b\"c"}d"
      "a#{?"}d"
      "a#{?}"abc"}d"
      "a#{\}}d"
      "a#{'b}c'}d"
      "a#{'b}c'}d"
      "#{{\ abcd\ }}"
      "#{{a:"b",c:"d"}}"
      "#{{{a:"b",c:"d"}}}"
      "#{{{a:"}",c:'}'}}}"
      %q|not\|interpolated|
      %q|not\
interpolated|
      %w.not\.interpolated.
      %i)not\)interpolated)
      %s^not\^interpolated^
      %%interpolated#{"%"}%
      %,inter\
polated#{"%"},
      %Q!interpolated#{"!"}!
      %Q#interpolated#{""}#
      %W"interpolated#{'"'}"
      %I~interpolated#{"~"}~
      %r$interpolated#{"$"}$
      %x/interpolated#{"/"}/
      %q(abcd)
      %w[abcd]
      %i<abcd>
      %s{abcd}
      %(ab#{")"}cd)
      %[ab#{"\]"}cd]
      %<ab#{">"}cd>
      %{ab#{"}"}cd}
      %%%
      %@#@a@
      %$#$a$
      "#{%%}%}"
      "#{%¬}"
      "#{%}"abc}}"
      "#{?}+""}"
      "#{match?}"
      "#{{a:1}}"
      "#{{a:1}'"'}"
      %q(12(34)56)
      %q[12[34]56]
      %q{12{34}56}
      %q<12<34>56>
      %(12(34)56)
      %[12[34]56]
      %{12{34}56}
      %<12<34>56>
    ]

    matched_strings.each { |string| assert_equal string, "a#{string}a".match(RBlade::RegularExpressions::RUBY_STRING)&.[](0) }

    unmatched_strings = %w[
      %q|asd.
      %-asd=
      %q|not|interpolated|
      %|inter|polated|
      "#{"
      %%#{%
      %¬abcd¬
      %$#$
      "#{%}"
      '#{'}'
      %q(12(34)
      %q[12\[34]
      %q{12{34}
      %q<12<34>
      %(12(34)
      %[12\[34]
      %{12{34}
      %<12<34>
    ]

    # rubocop:enable Lint/NestedPercentLiteral

    unmatched_strings.each { |string| refute_equal string, "a#{string}a".match(RBlade::RegularExpressions::RUBY_STRING)&.[](0) }
  end

  def test_interpolated_heredocs
    heredoc_strings = []

    heredoc_strings.push <<~HERE.strip
      <<END
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<"END"
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<-END
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<~END
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<-END
        123
        END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<~END
        123
        END
    HERE

    heredoc_strings.push <<~'HERE'.strip
      <<END
      #{
      END
      }
      END
    HERE

    heredoc_strings.push <<~'HERE'.strip
      <<-END
      #{
      END
      }
      END
    HERE

    heredoc_strings.push <<~'HERE'.strip
      <<~END
      #{
      END
      }
      END
    HERE

    heredoc_strings.each { |string| assert_equal string, "a#{string}\na".match(RBlade::RegularExpressions::RUBY_STRING)&.[](0) }
  end

  def test_non_interpolated_heredocs
    heredoc_strings = []

    heredoc_strings.push <<~HERE.strip
      <<'END'
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<-'END'
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<~'END'
      123
      END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<-'END'
        123
        END
    HERE

    heredoc_strings.push <<~HERE.strip
      <<~'END'
        123
        END
    HERE

    heredoc_strings.each { |string| assert_equal string, "a#{string}\na".match(RBlade::RegularExpressions::RUBY_STRING)&.[](0) }

    invalid_heredoc_strings = []

    invalid_heredoc_strings.push <<~'HERE'.strip
      <<'END'
      #{
      END
      }
      END
    HERE

    invalid_heredoc_strings.push <<~'HERE'.strip
      <<-'END'
      #{
      END
      }
      END
    HERE

    invalid_heredoc_strings.push <<~'HERE'.strip
      <<~'END'
      #{
      END
      }
      END
    HERE

    invalid_heredoc_strings.each { |string| refute_equal string, string.match(RBlade::RegularExpressions::RUBY_STRING)&.[](0) }
  end
end
