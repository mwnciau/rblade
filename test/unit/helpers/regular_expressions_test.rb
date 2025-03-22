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

    matched_strings.each { |string| assert string.match?(RBlade::RegularExpressions::RUBY_STRING), "String did not match: #{string}" }

    unmatched_strings = %w[
      %q|not|interpolated|
      %|inter|polated|
      "#{"
      %%#{%
      %¬abcd¬
      %$#$
      "#{%}"
      '#{'}'
    ]

    # rubocop:enable Lint/NestedPercentLiteral

    unmatched_strings.each { |string| assert !string.match?(RBlade::RegularExpressions::RUBY_STRING), "String matched: #{string}" }
  end
end
