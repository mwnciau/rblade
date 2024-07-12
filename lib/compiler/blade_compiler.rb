require_relative "concerns/compiles_echos"
require "htmlentities"

Token = Struct.new(:type, :value)

def dd *args
  print "\n\nDump and die output:\n"
  args.each do |arg| print arg.inspect, "\n" end
  print "\n"
  exit 0
end
def escape_quotes string
  string.gsub(/['"\\\x0]/, '\\\\\0')
end
def h string
  HTMLEntities.new.encode string
end


class BladeCompiler
  include CompilesEchos

  def self.compileString(stringTemplate)
    tokens = [Token.new(:unprocessed, stringTemplate)]

    CompilesEchos.compile_echos!(tokens)

    output = "_out='';";

    tokens.each do |token, cake|
      if token.type == :unprocessed
        output.<< "_out.<<'".<< escape_quotes(token.value) .<< "';"
      else
        output.<< token.value
      end
    end

    output
  end
end
