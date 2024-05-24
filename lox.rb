# frozen_string_literal: true

# Main file, handles running things

require_relative 'scanner'
require_relative 'parser'
require_relative 'ast_printer'
require_relative 'interpreter'

$interpreter = Interpreter.new
$had_error = false
$had_runtime_error = false

def run_file(path)
  file = File.open(path).read
  run file
  exit 65 if $had_error
  exit 70 if $had_runtime_error
end

def run_prompt
  loop do
    print 'lox> '
    line = gets.strip
    break if line.downcase == 'exit'

    run line
    $had_error = false
  end
end

def run(source)
  scanner = Scanner.new(source)
  tokens = scanner.scan_tokens
  parser = Parser.new(tokens)
  statements = parser.parse

  # Stop if there was a syntax error
  return if $had_error

  $interpreter.interpret statements
end

def error(line, message)
  report(line, '', message)
end

def runtime_error(error)
  warn "#{error.message}\n[line #{error.token.line}]"
  $had_runtime_error = true
end

def report(line, where, message)
  warn "[line #{line}] Error#{where}: #{message}"
  $had_error = true
end

def parse_error(token, message)
  if token.type == :EOF
    report(token.line, ' at end', message)
  else
    report(token.line, " at '#{token.lexeme}'", message)
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length > 1
    warn 'Usage: rlox [script]'
    exit 64
  elsif ARGV.length == 1
    run_file ARGV[0]
  else
    run_prompt
  end
end
