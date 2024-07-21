require "rblade/compiler/compiles_comments"
require "rblade/compiler/compiles_components"
require "rblade/compiler/compiles_echos"
require "rblade/compiler/compiles_ruby"
require "rblade/compiler/compiles_statements"
require "rblade/compiler/tokenizes_components"
require "rblade/compiler/tokenizes_statements"

Token = Struct.new(:type, :value)

def dd(*)
  print "\n\ndd output:\n"
  pp(*)
  exit 0
end

def escape_quotes string
  string.gsub(/['\\\x0]/, '\\\\\0')
end

if !defined?(h)
  require 'erb/escape'
  define_method(:h, ERB::Escape.instance_method(:html_escape))
end

module RBlade
  class Compiler
    def self.compileString(string_template)
      tokens = [Token.new(:unprocessed, string_template)]

      CompilesComments.new.compile! tokens
      CompilesEchos.new.compile! tokens
      CompilesRuby.new.compile! tokens
      TokenizesComponents.new.tokenize! tokens
      TokenizesStatements.new.tokenize! tokens
      CompilesStatements.new.compile! tokens
      CompilesComponents.new.compile! tokens

      compileTokens tokens
    end

    def self.compileAttributeString(string_template)
      tokens = [Token.new(:unprocessed, string_template)]

      CompilesRuby.compile! tokens
      CompilesComments.compile!(tokens)
      CompilesEchos.compile!(tokens)

      compileTokens tokens
    end

    def self.compileTokens tokens
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
end
