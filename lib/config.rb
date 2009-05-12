require "singleton"

module Traquitana
	class Config
		include Singleton

		def initialize
			@configs = {}
		end

		def dir
			"traq"
		end

		def config
			"#{dir}/config.yml"
		end

		def default
			"#{File.dirname(File.expand_path(__FILE__))}/../config/default.yml"
		end

		def load
			@configs = YAML.load(File.read(config))
		end

		def method_missing(meth)
			c = @configs[meth.to_sym]
			c ? c : ""
		end
	end
end
