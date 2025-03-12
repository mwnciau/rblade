# frozen_string_literal: true

require "rblade/compiler/compiles_comments"
require "rblade/compiler/compiles_components"
require "rblade/compiler/compiles_prints"
require "rblade/compiler/compiles_ruby"
require "rblade/compiler/compiles_verbatim"
require "rblade/compiler/compiles_statements"
require "rblade/compiler/tokenizes_components"
require "rblade/compiler/tokenizes_statements"
require "active_support/core_ext/string/output_safety"

Token = Struct.new(:type, :value)

module RBlade
  def self.escape_quotes string
    string.gsub(/['\\\x0]/, '\\\\\0')
  end

  class RBladeTemplateError < StandardError; end

  # Register a new custom directive by providing a proc that will return a value to be output
  #
  # @param [String] name The directive tag without the "@", e.g. "if" for the "@if" directive
  # @param [Proc] block The block that will return the compiled ruby code for the directive. Can accept `:args`, `:tokens` and `:token_index` as arguments.
  # @return [void]
  def self.register_directive_handler(name, &)
    CompilesStatements.register_handler(name, &)
  end

  # Register a new custom directive by providing a proc that will return ruby code to add to the template. The code must end in a semi-colon.
  #
  # @param [String] name The directive tag without the "@", e.g. "if" for the "@if" directive
  # @param [Proc] block The block that will return the compiled ruby code for the directive. Can accept `:args`, `:tokens` and `:token_index` as arguments.
  # @return [void]
  def self.register_raw_directive_handler(name, &)
    CompilesStatements.register_raw_handler(name, &)
  end

  class Compiler
    def self.compileString(string_template, component_store)
      tokens = [Token.new(:unprocessed, string_template)]

      CompilesVerbatim.new.compile! tokens
      CompilesComments.new.compile! tokens
      CompilesRuby.new.compile! tokens
      TokenizesComponents.new.tokenize! tokens
      CompilesPrints.new.compile! tokens
      TokenizesStatements.new.tokenize! tokens
      CompilesStatements.new.compile! tokens

      component_compiler = CompilesComponents.new(component_store)
      component_compiler.compile! tokens
      component_compiler.ensure_all_tags_closed
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

      i = 0
      while i < tokens.count
        token = tokens[i]
        if token.type == :unprocessed || token.type == :raw_text
          output << "@output_buffer.raw_buffer<<-'"

          # Merge together consecutive prints
          while tokens[i + 1]&.type == :unprocessed || tokens[i + 1]&.type == :raw_text
            output << RBlade.escape_quotes(token.value)
            i += 1
            token = tokens[i]
          end

          output << RBlade.escape_quotes(token.value)
          output << "';"
        else
          output << token.value
        end
        i += 1
      end

      output
    end
  end
end
