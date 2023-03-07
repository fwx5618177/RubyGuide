require "memoist"

class Example
    extend Memoist

    def slow(n)
        sleep(2)
        n * n
    end

    memoize :slow
end

ex = Example.new

puts ex.slow(10)

puts ex.slow(10)

puts ex.slow(20)