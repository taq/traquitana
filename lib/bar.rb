module Traquitana
  class Bar
    attr_reader   :current
    attr_accessor :name, :total

    def initialize
      reset
    end      

    def reset
      @name     = nil
      @total    = 0
      @current  = 0
      @bar_size = 20
      @bar_step = 5
    end

    def indicator(current)
      bar = Array.new(@bar_size, "_")
      return bar.join if current <= 0

      prop = current > 0 ? ((100 / (total / current.to_f)) / @bar_step).to_i : 0
      return bar.join if prop <= 0

      bar[0...prop] = Array.new(prop, "#")
      bar.join
    end

    def update(current)
      @current = current
      file     = File.basename(@name).ljust(25)
      STDOUT.print "#{file} : #{self.indicator(current)}\r"

      if @current >= @total
        STDOUT.puts "\n"
        @current = -1
      end
    end
  end
end
