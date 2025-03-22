module RBlade::RegularExpressions
  RUBY_STRING = /
    \A
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
            |
            (?<=\w)\?
            |
            (?# A percentage sign that's not a percent literal)
            %(?![qwisQWIrx]?+[\x00-\x7F&&[^a-zA-Z0-9(\[{<]])
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
        \( (?: [^)\\]++ | \\. )*+ \)
        |
        \[ (?: [^\]\\]++ | \\. )*+ \]
        |
        < (?: [^>\\]++ | \\. )*+ >
        |
        \{ (?: [^}\\]++ | \\. )*+ \}
        |
        (?<nid>[\x00-\x7F&&[^a-zA-Z0-9(\[{<]])
        (?:
          [a-zA-Z0-9(\[{<[^\x00-\x7F]]++
          |
          \\.
          |
          (?!\k<nid>)[^\\]
        )*?
        \k<nid>
      )
    |
    (?# Interpolated percent expressions )
    %[QWIrx]?
      (?:
        \( (?: [^)\\#]++ | \#\g<curly> | \\. )*+ \)
        |
        \[ (?: [^\]\\#]++ | \#\g<curly> | \\. )*+ \]
        |
        < (?: [^>\\#]++ | \#\g<curly> | \\. )*+ >
        |
        \{ (?: [^}\\#]++ | \#\g<curly> | \\. )*+ \}
        |
        (?<id>[\x00-\x7F&&[^a-zA-Z0-9(\[{<]])
        (?:
          [a-zA-Z0-9(\[{<[^\x00-\x7F]]++
          |
          \#\g<curly>
          |
          \\.
          |
          (?!\k<id>)[^\\#]
          |
          (?!\#\{)\#[@$]?+
        )*?
        (?!\#\{)\k<id>
      )
    |
    (?<!\w)\?.
    )
    \z
  /mx
end
