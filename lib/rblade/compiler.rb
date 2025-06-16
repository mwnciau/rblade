# frozen_string_literal: true

require "rblade/compiler/compiles_comments"
require "rblade/compiler/compiles_components"
require "rblade/compiler/compiles_injections"
require "rblade/compiler/compiles_verbatim"
require "rblade/compiler/compiles_statements"
require "rblade/compiler/tokenizes_components"
require "rblade/compiler/tokenizes_statements"
require "rblade/helpers/utility"
require "active_support/core_ext/string/output_safety"

Token = Struct.new(:type, :value, :start_offset, :end_offset)

module RBlade
  def self.escape_quotes(string)
    string&.gsub(/['\\\x0]/, '\\\\\0')
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
    def self.compile_string(string_template, component_store)
      tokens = tokenize_string string_template, component_store

      compile_tokens tokens
    end

    def self.generate_source_map(string_template, component_store)
      tokens = tokenize_string string_template, component_store
      source_map = SourceMap.new(string_template)

      i = 0
      while i < tokens.count
        token = tokens[i]

        if token.type == :unprocessed || token.type == :raw_text
          start_offset = token.start_offset
          compiled_code = +"@output_buffer.raw_buffer<<-'"

          # Merge together consecutive prints
          while tokens[i + 1]&.type == :unprocessed || tokens[i + 1]&.type == :raw_text
            compiled_code << RBlade.escape_quotes(token.value)
            i += 1
            token = tokens[i]
          end

          compiled_code << RBlade.escape_quotes(token.value)
          compiled_code << "';"

          source_map.add(start_offset, token.end_offset, compiled_code)
        else
          source_map.add(token.start_offset, token.end_offset, token.value)
        end

        i += 1
      end

      source_map
    end

    def self.tokenize_string(string_template, component_store)
      tokens = [Token.new(:unprocessed, string_template, 0, string_template.length)]

      CompilesVerbatim.new.compile! tokens
      CompilesComments.new.compile! tokens
      TokenizesComponents.new.tokenize! tokens
      CompilesInjections.new.compile! tokens
      TokenizesStatements.new.tokenize! tokens
      CompilesStatements.new.compile! tokens

      component_compiler = CompilesComponents.new(component_store)
      component_compiler.compile! tokens
      component_compiler.ensure_all_tags_closed

      tokens
    end

    def self.compile_attribute_string(string_template)
      tokens = [Token.new(:unprocessed, string_template)]

      CompilesComments.compile!(tokens)
      CompilesRuby.compile! tokens
      CompilesPrints.compile!(tokens)

      compile_tokens tokens
    end

    def self.compile_tokens(tokens)
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
