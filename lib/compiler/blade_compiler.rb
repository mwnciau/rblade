require_relative "concerns/compiles_comments"
require_relative "concerns/compiles_echos"
require_relative "concerns/compiles_statements"
require_relative "concerns/tokenizes_statements"
require "htmlentities"
require "pp"

Token = Struct.new(:type, :value)

def dd(*)
  print "\n\ndd output:\n"
  pp(*)
  exit 0
end

def escape_quotes string
  string.gsub(/['"\\\x0]/, '\\\\\0')
end

def h string
  HTMLEntities.new.encode string
end

class BladeCompiler
  def self.compileString(stringTemplate)
    tokens = [Token.new(:unprocessed, stringTemplate)]

    CompilesComments.compile!(tokens)
    TokenizesComponents.tokenize!(tokens)
    TokenizesStatements.tokenize!(tokens)
    CompilesStatements.compile!(tokens)
    CompilesEchos.compile!(tokens)

    output = ""

    tokens.each do |token, cake|
      if token.type == :unprocessed || token.type == :raw_text
        output << "_out<<'" << escape_quotes(token.value) << "';"
      else
        output << token.value
      end
    end

    output
  end
end
