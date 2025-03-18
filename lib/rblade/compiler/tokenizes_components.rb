# frozen_string_literal: true

require "ripper"

module RBlade
  class TokenizesComponents
    def tokenize!(tokens)
      tokens.map! do |token|
        next(token) if token.type != :unprocessed

        segments = tokenize_component_tags token.value

        i = 0
        while i < segments.count
          if segments[i] == "</" && segments[i + 1]&.match?(/x[-:]/)
            segments[i] = Token.new(type: :component_end, value: {name: segments[i + 1][2..]})

            segments.delete_at i + 1
            i += 1
          elsif segments[i] == "<//>"
            segments[i] = Token.new(type: :component_unsafe_end)
            i += 1
          elsif segments[i] == "<" && segments[i + 1]&.match?(/x[-:]/)
            name = segments[i + 1][2..]
            raw_attributes = (segments[i + 2] != ">") ? tokenize_attributes(segments[i + 2]) : nil

            attributes = process_attributes raw_attributes

            if raw_attributes.nil?
              segments.delete_at i + 1
            else
              while segments[i + 1] != ">" && segments[i + 1] != "/>"
                segments.delete_at i + 1
              end
            end

            token_type = (segments[i + 1] == "/>") ? :component : :component_start
            segments[i] = Token.new(type: token_type, value: {name:, attributes:})
            segments.delete_at i + 1

            i += 1
          elsif !segments[i].nil? && segments[i] != ""
            segments[i] = Token.new(type: :unprocessed, value: segments[i])

            i += 1
          else
            segments.delete_at i
          end
        end

        segments
      end.flatten!
    end

    private

    def process_attributes(raw_attributes)
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

    def tokenize_component_tags(value)
      value.split(%r/
        # Opening and self-closing tags
        (?:
          (<)
            \s*+
            (x[-\:][\w\-\:\.]++)
            ((?:
              \s++
              (?:
                (?:
                  @class(\( (?: [^()]++ | \g<-1> )*+ \))
                )
                |
                (?:
                  @style(\( (?: [^()]++ | \g<-1> )*+ \))
                )
                |
                (
                  \{\{ \s*+ attributes (?:[^}]++|\})*? \}\}
                )
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
            )*+)
            \s*+
          (\/?>)
        )
        |
        # Closing tags
        (?:
          (<\/)
            \s*+
            (x[-\:][\w\-\:\.]++)
            \s*+
          >
        )
        |
        (<\/\/>)
      /x)
    end

    def tokenize_attributes(segment)
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
