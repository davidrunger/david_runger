# frozen_string_literal: true

class OS
  class << self
    extend Memoist

    memoize \
    def mac?
      `echo $OSTYPE`.include?('darwin')
    end
  end
end
