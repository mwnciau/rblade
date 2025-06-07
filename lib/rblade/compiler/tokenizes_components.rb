# frozen_string_literal: true

require "ripper"

module RBlade
  class TokenizesComponents
    def tokenize!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        process_component_tags token
      end.flatten!
    end

    private def process_component_tags(token)
      current_match_id = nil
      segments = []

      token.value.split(%r/
        # Opening and self-closing tags
        (?<opening_tag>
          <
            \s*+
            x[-\:](?<opening_tag_name>[\w\-\:\.]++)
            (?<tag_attributes>
              (?:
                \s++
                (?:
                  (?:
                    @class(?<nested_parentheses>\( (?: [^()]++ | \g<nested_parentheses> )*+ \))
                  )
                  |
                  (?:
                    @style\g<nested_parentheses>
                  )
                  |
                  \{\{ \s*+ attributes (?:[^}]++|\})*? \}\}
                  |
                  (?:
                    [\w\-:.@%]++
                    (?:
                      =
                      (?:
                        "(?> [^"{]++ | (?<!@)\{\{ (?:[^}]++|\})*? \}\} | \{ )*+"
                        |
                        '(?> [^'{]++ | (?<!@)\{\{ (?:[^}]++|\})*? \}\} | \{ )*+'
                        |
                        (?> [^'"=<>\s\/{]++ | (?<!@)\{\{ (?:[^}]++|\})*? \}\} | \{ )++
                      )
                    )?
                  )
                )
              )*+
            )
            \s*+
          (?<opening_tag_end>\/?>)
        )
        |
        # Closing tags
        (?<closing_tag>
          <\/
            \s*+
            x[-\:](?<closing_tag_name>[\w\-\:\.]++)
            \s*+
          >
        )
        |
        (?<unsafe_closing_tag><\/\/>)
      /x) do |before_match|
        next if current_match_id == $~.object_id
        current_match_id = $~.object_id

        # Add the current string to the segment list
        unless before_match == ""
          RBlade::Utility.append_unprocessed_string_segment!(token, segments, before_match)
        end
        next if $~.nil?

        start_offset = segments.last&.end_offset || token.start_offset
        if $~[:unsafe_closing_tag].present?
          segments << Token.new(
            type: :component_unsafe_end,
            start_offset: start_offset,
            end_offset: start_offset + $&.length,
          )
        elsif $~[:closing_tag].present?
          segments << Token.new(
            type: :component_end,
            value: {name: $~[:closing_tag_name]},
            start_offset: start_offset,
            end_offset: start_offset + $&.length,
          )
        elsif $~[:opening_tag].present?
          raw_attributes = tokenize_attributes($~[:tag_attributes])
          attributes = process_attributes raw_attributes

          token_type = ($~[:opening_tag_end] == "/>") ? :component : :component_start
          segments << Token.new(
            type: token_type,
            value: {name: $~[:opening_tag_name], attributes:},
            start_offset: start_offset,
            end_offset: start_offset + $&.length,
          )
        end
      end

      segments
    end

    private def process_attributes(raw_attributes)
      attributes = []
      i = 0
      while i < raw_attributes.count
        name = raw_attributes[i]
        if name == "@class" || name == "@style"
          attributes.push({type: name[1..], value: raw_attributes[i + 1][1..-2]})
          i += 2
        elsif name == "{{"
          attributes.push({type: "attributes", value: raw_attributes[i + 1]})
          i += 3
        else
          attribute = {}

          if raw_attributes[i + 1] == "="
            attribute[:value] = raw_attributes[i + 2]
            i += 3
          else
            i += 1
          end

          # The "::" at the start of attributes is used to escape attribute names beginning with ":"
          if name[0..1] == "::"
            attribute[:type] = "string"
            attribute[:name] = name[1..]
            attributes.push(attribute)
            next
          end

          # If the entire value is a single interpolated string, make this a ruby value
          if attribute[:value]&.match?(/\A\{\{([^}]++|(?!\}\})\})*\}\}\z/)
            attribute[:type] = "ruby"
            attribute[:name] = name
            attribute[:value] = attribute[:value][2..-3]
            attributes.push(attribute)
            next
          end

          if name[0] == ":"
            attribute[:type] = attribute[:value].nil? ? "pass_through" : "ruby"
            attribute[:name] = name[1..]
            attributes.push(attribute)
            next
          end

          attribute[:name] = name
          attribute[:type] = if attribute[:value].nil?
            "empty"
          else
            "string"
          end
          attributes.push(attribute)
        end
      end

      attributes
    end

    private def tokenize_attributes(segment)
      segment.scan(%r/
        (?<=\s|^)
        (?:
          (?:
            (@class)(\( (?: (?>[^()]+) | \g<-1> )*+ \))
          )
          |
          (?:
            (@style)(\( (?: (?>[^()]+)| \g<-1> )*+ \))
          )
          |
          (?:
            (\{\{) \s*+ (attributes(?:[^}\s]++|\}|\s)*?) \s*+ (\}\})
          )
          |
          (?:
            ([\w\-:.@%]+)
            (?:
              (=)
              (?:
                "((?> [^"{]++ | (?<!@)\{\{ (?:[^}]++|\})*? \}\} | \{ )*+)"
                |
                '((?> [^'{]++ | (?<!@)\{\{ (?:[^}]++|\})*? \}\} | \{ )*+)'
                |
                ((?> [^'"=<>\s\/{]++ | (?<!@)\{\{(?:[^}]++|\})*?\}\} | \{ )*+)
              )
            )?
          )
        )
        (?=\s|$)
      /x).flatten.compact
    end
  end
end
