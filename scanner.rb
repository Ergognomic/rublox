# frozen_string_literal: true

require_relative 'token'

# Lox scanner class
class Scanner
  @@keywords = {
    'and' => :AND,
    'class' => :CLASS,
    'else' => :ELSE,
    'false' => :FALSE,
    'for' => :FOR,
    'fun' => :FUN,
    'if' => :IF,
    'nil' => :NIL,
    'or' => :OR,
    'print' => :PRINT,
    'return' => :RETURN,
    'super' => :SUPER,
    'this' => :THIS,
    'true' => :TRUE,
    'var' => :VAR,
    'while' => :WHILE
  }

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until @current == @source.length
      @start = @current
      scan_token
    end
    @tokens.push(Token.new(:EOF, '', nil, @line))
  end

  def at_end?
    @current >= @source.length
  end

  def chomp
    @current += 1
    @source[@current - 1]
  end

  def add_token(type, literal = nil)
    text = @source[@start...@current]
    @tokens.push(Token.new(type, text, literal, @line))
  end

  def scan_token
    c = chomp
    case c
    when '('
      add_token :LEFT_PAREN
    when ')'
      add_token :RIGHT_PAREN
    when '{'
      add_token :LEFT_BRACE
    when '}'
      add_token :RIGHT_BRACE
    when ','
      add_token :COMMA
    when '.'
      add_token :DOT
    when '-'
      add_token :MINUS
    when '+'
      add_token :PLUS
    when ';'
      add_token :SEMICOLON
    when '*'
      add_token :STAR
    when '!'
      add_token(match('=') ? :BANG_EQUAL : :BANG)
    when '='
      add_token(match('=') ? :EQUAL_EQUAL : :EQUAL)
    when '<'
      add_token(match('=') ? :LESS_EQUAL : :LESS)
    when '>'
      add_token(match('=') ? :GREATER_EQUAL : :GREATER)
    when '/'
      if match '/'
        chomp while peek != "\n" && !at_end?
      else
        add_token :SLASH
      end
    when "\n"
      @line += 1
    when '"'
      scan_string
    when /\d/
      scan_number
    when /[a-zA-z_]/
      scan_identifier
    else
      error(@line, "Unexpected character: '#{c}'") unless c.match?(/\s/)
    end
  end

  def scan_identifier
    chomp while peek&.match?(/[a-zA-Z_0-9]/)
    text = @source[@start...@current]
    type = @@keywords[text]
    type = :IDENTIFIER if type.nil?
    add_token(type)
  end

  def scan_number
    chomp while peek&.match?(/\d/)
    if peek && peek == '.' && peek_next&.match?(/\d/)
      chomp
      chomp while peek&.match?(/\d/)
    end
    add_token(:NUMBER, @source[@start...@current].to_f)
  end

  def scan_string
    until peek == '"' || at_end?
      @line += 1 if peek == "\n"
      chomp
    end
    if at_end?
      error(@line, 'Unterminated string.')
      return
    end
    chomp
    value = @source[(@start + 1)...(@current - 1)]
    add_token(:STRING, value)
  end

  # Looks ahead one character and consumes it if it matches the expected
  def match(expected)
    return false if at_end?
    return false if @source[@current] != expected

    @current += 1
    true
  end

  # Looks ahead one character and returns nil if there's nothing there
  def peek
    return nil if at_end?

    @source[@current]
  end

  # Looks ahead two characters and returns nil if there's nothing there
  def peek_next
    @current + 1 >= @source.length ? nil : @source[@current + 1]
  end
end
