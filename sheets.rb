# hacky little thing that spits out random arithmetic sheets given some basic input.
require 'pdf/writer'
require 'optparse'

pdf = PDF::Writer.new(:paper => "A4")
supported_operators = %w{x + - %}
supported_range = 1..4

# accept some options
options, @answers = {}, {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: sheets.rb -t 2 -b 1 -o 'x'"

  options[:top] = 2
  options[:bottom] = 1
  options[:answers] = true
  options[:operator] = 'x'

  opts.on('-t', '--top x', "Number (x) of digits in top number") { |n| options[:top] = n }
  opts.on('-b', '--bottom x', 'Number (x) of digits in bottom number') { |n| options[:bottom] = n }
  opts.on('-o', '--operator "x"', 'The character representation of the operator') { |n| options[:operator] = n }
  opts.on('-a', '--answers', 'Provide if you want an additional sheet containing the answers') { |n| options[:operator] = true }

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!
if options[:bottom].to_i > options[:top].to_i
  puts "This only supports the top number being bigger or equal in size to the bottom"
  exit
end

if !(supported_range === options[:bottom].to_i) || !(supported_range === options[:top].to_i)
  puts "This only supports positive integers, up to 4!"
  exit
end

unless supported_operators.include?(options[:operator])
  puts "Oops!  You have to use a simple arithmetic operator!"
  exit
end


# some helper methods
def number(digi)
  num = (rand(10**digi) + 1).to_s
  num.size != digi ? number(digi) : (return num)
end

def calculate(top, bottom, operator)
  top, bottom = top.to_i, bottom.to_i
  case operator
    when "+": top + bottom
    when "-": top - bottom
    when "x": top * bottom
    when "%": top / bottom
  end
end

def space_bottom(top, bottom, operator)
  " " * if operator == "-"
    top - bottom + 1
  elsif operator == "%"
    if top - bottom > 0
      top - bottom - 1
    else
      0
    end
  else
    top - bottom
  end
end

def space_top(top, bottom)
  " " * case (top - bottom)
    when 1: 2
    when 2: 1
    when 3: 0
    else 3
  end
end

# start pdf routine
pdf.start_columns(8)

1.upto(104) do |i|
  top, bottom, operator = options[:top].to_i, options[:bottom].to_i, options[:operator]
  number_top, number_bottom = number(top), number(bottom)
  pdf.text "#{space_top(top,bottom)}#{number_top}", :font_size => 16
  pdf.move_pointer(1)
  pdf.text "<c:uline>#{options[:operator]} #{space_bottom(top,bottom,operator)}#{number_bottom}</c:uline>"
  pdf.move_pointer(20)

  if options[:answers]
    @answers[i.to_s] = calculate(number_top, number_bottom, operator)
  end
end

if options[:answers]
  pdf.start_new_page
  1.upto(104) do |i|
    pdf.text "#{@answers[i.to_s]}", :font_size => 16
    pdf.move_pointer(40)
  end
end

pdf.save_as "test.pdf"
