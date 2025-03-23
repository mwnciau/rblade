module RBlade::RegularExpressions
  RUBY_STRING_CHARACTERS = "\"'%?"
  RUBY_STRING = /
    (?<string>
    (?# Interpolated strings )
    "
      (?:
        [^#"\\]++
        |
        \#(?<curly>\{
          (?:
            [^"'{}?%]++
            |
            \g<string>
            |
            \g<curly>
          )*+
        \})
        |
        \\.
        |
        (?!\#\{)\#[@$]?
      )*+
    "
    |
    (?# Non interpolated strings )
    '
      (?:
        [^'\\]++
        |
        \\.
      )*+
    '
    |
    (?# Non interpolated percent expressions )
    %[qwis]
      (?:
        (?<ni_parentheses> \( (?: [^()\\]++ | \\. | \g<ni_parentheses> )*+ \) )
        |
        (?<ni_brackets> \[ (?: [^\[\]\\]++ | \\. | \g<ni_brackets> )*+ \] )
        |
        (?<ni_crocs> < (?: [^<>\\]++ | \\. | \g<ni_crocs> )*+ > )
        |
        (?<ni_braces> \{ (?: [^{}\\]++ | \\. | \g<ni_braces> )*+ \} )
        |
        (?<percent_delimiter>[\x00-\x7F&&[^a-zA-Z0-9(\[{<]])
        (?:
          [a-zA-Z0-9(\[{<[^\x00-\x7F]]++
          |
          \\.
          |
          (?!\k<percent_delimiter>)[^\\]
        )*?
        \k<percent_delimiter>
      )
    |
    (?# Interpolated percent expressions )
    %[QWIrx]?
      (?:
        (?<i_parentheses> \( (?: [^()\\#]++ | \#\g<curly> | \\. | \g<i_parentheses> )*+ \) )
        |
        (?<i_brackets> \[ (?: [^\[\]\\#]++ | \#\g<curly> | \\. | \g<i_brackets> )*+ \] )
        |
        (?<i_crocs> < (?: [^<>\\#]++ | \#\g<curly> | \\. | \g<i_crocs> )*+ > )
        |
        (?<i_braces> \{ (?: [^{}\\#]++ | \#\g<curly> | \\. | \g<i_braces> )*+ \} )
        |
        \g<percent_delimiter>
        (?:
          [a-zA-Z0-9(\[{<[^\x00-\x7F]]++
          |
          \#\g<curly>
          |
          \\.
          |
          (?!\k<percent_delimiter>)[^\\#]
          |
          (?!\#\{)\#[@$]?+
        )*?
        (?!\#\{)\k<percent_delimiter>
      )
    |
    (?<!\w)\?.
    |
    (?# Consume characters that don't end up being string literals)
    (?<=\w)\?
    |
    (?# A percentage sign that's not a percent literal)
    %(?![qwisQWIrx]?+\g<percent_delimiter>)
    )
  /mx
end
