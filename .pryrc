# frozen_string_literal: true

require 'amazing_print'
# similar to `AmazingPrint.pry!`, but with `=> ` at the beginning
Pry.print = proc { |output, value| output.puts("=> #{value.ai}") }
