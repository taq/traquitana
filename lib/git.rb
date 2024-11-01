module Traquitana
  class Git
    def self.current_branch
      IO.popen('git rev-parse --abbrev-ref HEAD') do |io|
        io.read.chomp
      end
    rescue
      nil
    end
  end
end
