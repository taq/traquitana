require "singleton"

module Traquitana
   class Config
      include Singleton

      def initialize
         @configs = {}
      end

      def filename
         "config/traq.yml"
      end

      def default
         "#{File.dirname(File.expand_path(__FILE__))}/../config/default.yml"
      end

      def load(file=nil)
         @configs = YAML.load(File.read(file || self.filename))
      end

      def method_missing(meth)
         @configs[meth.to_s] || ""
      end

      def setup
			STDOUT.puts "Running setup"
         if File.exists?(self.filename)
            STDERR.puts "The configuration file #{self.filename} already exists."
            return false
         end

         dir = File.dirname(self.filename)
			Dir.mkdir(dir) if !File.exist?(dir)

			STDOUT.puts "Writing #{self.filename}"
			File.open(self.filename,"w") do |file|
				file << "# Default configuration"
				file << File.read(self.default)
			end

			STDOUT.puts "Setup completed!"
			STDOUT.puts "You MUST check the configurations on #{self.filename} before deploying!"
         true
      end
   end
end
