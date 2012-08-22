module Traquitana
   class Cleaner
      attr_accessor :network

      def initialize
         @config  = Traquitana::Config.instance
         @config.load
         @network = Traquitana::SSH.new(@config.host,@config.user)
      end

      def run
         STDOUT.print "Cleaning old files ... "
         @network.execute(["find #{@config.directory}/traq -type f -iname '*.zip' -o -iname '*.list' | sort | head -n-2 | xargs rm $1"])
         STDOUT.puts "done."
      end
   end
end
