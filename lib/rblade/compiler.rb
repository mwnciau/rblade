# frozen_string_literal: true

require "rblade/compiler/compiles_comments"
require "rblade/compiler/compiles_components"
require "rblade/compiler/compiles_prints"
require "rblade/compiler/compiles_ruby"
require "rblade/compiler/compiles_verbatim"
require "rblade/compiler/compiles_statements"
require "rblade/compiler/tokenizes_components"
require "rblade/compiler/tokenizes_statements"
require "rblade/helpers/html_string"
require "active_support/core_ext/string/output_safety"

Token = Struct.new(:type, :value)

if !defined?(h)
  require "erb/escape"
  define_method(:h, ERB::Escape.instance_method(:html_escape))
end

module RBlade
  def self.escape_quotes string
    string.gsub(/['\\\x0]/, '\\\\\0')
  end

  def self.e(string)
    if string.is_a?(HtmlString) || string.is_a?(ActiveSupport::SafeBuffer)
      string
    else
      h(string)
    end
  end

  # Register a new custom directive by providing a class and method that will compile the directive into ruby code.
  #
  # @param [String] name The directive tag without the "@", e.g. "if" for the "@if" directive
  # @param [Object] handler_class The class that will handle the directive, which will be initialized the first time the directive is used
  # @param [Symbol] method The method in `handler_class` that will process the directive and return the compiled ruby code. Any arguments will be passed to this method as an array.
  # @return [void]
  def self.register_directive_handler(name, handler_class, method)
    CompilesStatements.register_handler name, handler_class, method
  end

  class Compiler
    def self.compileString(string_template)
      tokens = [Token.new(:unprocessed, string_template)]

      CompilesVerbatim.new.compile! tokens
      CompilesComments.new.compile! tokens
      CompilesRuby.new.compile! tokens
      TokenizesComponents.new.tokenize! tokens
      CompilesPrints.new.compile! tokens
      TokenizesStatements.new.tokenize! tokens
      CompilesStatements.new.compile! tokens
      CompilesComponents.new.compile! tokens

      compileTokens tokens
    end

    def self.compileAttributeString(string_template)
      tokens = [Token.new(:unprocessed, string_template)]

      CompilesComments.compile!(tokens)
      CompilesRuby.compile! tokens
      CompilesPrints.compile!(tokens)

      compileTokens tokens
    end

    def self.compileTokens tokens
      output = +""

      tokens.each do |token|
        output << if token.type == :unprocessed || token.type == :raw_text
          "_out<<'#{RBlade.escape_quotes(token.value)}';"
        else
          token.value
        end
      end

      output
    end
  end
end
