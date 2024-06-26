# frozen_string_literal: true

def define_ast(output_directory, base_name, types)
  path = "#{output_directory}/#{base_name}.rb"
  open(path, 'w') do |file|
    file.puts '# frozen_string_literal: true'
    file.puts
    file.puts '# This file was auto-generated by generate_ast.'
    file.puts
    define_visitor(file, base_name, types)
    file.puts '# Pseudo virtual class for expressions'
    file.puts "class #{base_name.capitalize}"
    file.puts '  def initialize(*) end'
    file.puts
    file.puts '  def accept(*)'
    file.puts "    warn 'runtime error: unimplemented function: accept'"
    file.puts '    exit 1'
    file.puts '  end'
    file.puts 'end'
    # The AST classes
    types.each do |type|
      class_name = type.split(':')[0].strip
      attrs = type.split(':')[1].strip
      define_type(file, base_name, class_name, attrs)
    end
  end
end

def define_visitor(file, base_name, types)
  file.puts '# Pseudo-interface for classes that visit the AST'
  file.puts 'class Visitor'
  types.each do |type|
    type_name = type.split(':')[0].strip
    file.puts "  def visit_#{type_name.downcase}_#{base_name}(*)"
    file.puts "    warn 'runtime error: unimplemented function: visit_#{type_name.downcase}_#{base_name}'"
    file.puts '    exit 1'
    file.puts '  end'
    file.puts if type != types.last
  end
  file.puts 'end'
  file.puts
end

def define_type(file, base_name, class_name, attr_list)
  file.puts
  file.puts "# Represents #{class_name.downcase} #{base_name} nodes in the AST"
  file.puts "class #{class_name} < #{base_name.capitalize}"
  attrs = attr_list.split(', ').map { |str| ":#{str}" }.join(', ')
  file.puts "  attr_accessor #{attrs}"
  file.puts
  # Constructor
  file.puts "  def initialize(#{attr_list})"
  file.puts '    super'
  # Initialize attrs
  attrs = attr_list.split(', ')
  attrs.each do |attr|
    file.puts "    @#{attr} = #{attr}"
  end
  file.puts '  end'
  file.puts
  file.puts '  def accept(visitor)'
  file.puts "    visitor.visit_#{class_name.downcase}_#{base_name}(self)"
  file.puts '  end'
  file.puts 'end'
end

if __FILE__ == $PROGRAM_NAME
  if ARGV.length != 1
    warn 'Usage: generate_ast <output_directory>'
    warn '<output_directory> is typically ".\"'
    exit 64
  end

  output_directory = ARGV[0]
  define_ast(output_directory, 'expr', [
               'Assign   : name, value',
               'Binary   : left, operator, right',
               'Call     : callee, paren, arguments',
               'Grouping : expression',
               'Literal  : value',
               'Logical  : left, operator, right',
               'Unary    : operator, right',
               'Variable : name'
             ])

  define_ast(output_directory, 'stmt', [
               'Block      : statements',
               'Expression : expression',
               'Function   : name, params, body',
               'If         : condition, then_branch, else_branch',
               'Print      : expression',
               'Return     : keyword, value',
               'Var        : name, initializer',
               'While      : condition, body'
             ])
end
