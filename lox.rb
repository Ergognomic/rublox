# frozen_string_literal: true

# Main file, handles running things

require_relative 'scanner'

$hadError = false

def run_file(path)
  file = File.open(path).read
  run file
  exit 65 if $hadError
end

def run_prompt
  loop do
    print 'lox> '
    line = gets.strip
    break if line.downcase == 'exit'

    run line
    $hadError = false
  end
end

def run(source)
  scanner = Scanner.new(source)
  tokens = scanner.scan_tokens

  tokens.each do |token|
    puts token.to_string
  end
end

def error(line, message)
  report(line, '', message)
end

def report(line, where, message)
  warn "[line #{line}] Error#{where}: #{message}"
  $hadError = true
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length > 1
    puts 'Usage: rlox [script]'
    exit 64
  elsif ARGV.length == 1
    run_file ARGV[0]
  else
    run_prompt
  end
end
