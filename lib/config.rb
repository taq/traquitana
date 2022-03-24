require 'singleton'

module Traquitana
  class Config
    include Singleton
    attr_accessor :filename, :target

    def initialize
      @configs  = {}
      @filename = 'config/traq.yml'
      @target   = nil
      load
    end

    def default
      "#{File.dirname(File.expand_path(__FILE__))}/../config/default.yml"
    end

    def load(file = nil)
      check_configs(file)
      check_target
      check_default_target
    end

    def method_missing(meth)
      @configs[meth.to_s] || ''
    end

    def setup
      STDOUT.puts 'Running setup'

      if File.exist?(self.filename)
        STDERR.puts "The configuration file #{self.filename} already exists."
        return false
      end

      dir = File.dirname(filename)
      Dir.mkdir(dir) if !File.exist?(dir)

      STDOUT.puts "Writing #{filename}"
      File.open(filename, "w") do |file|
        file << File.read(self.default)
      end

      STDOUT.puts "Setup completed!"
      STDOUT.puts "You MUST check the configurations on #{self.filename} before deploying!"
      true
    end

    private

    def check_configs(file)
      @configs = YAML.load(File.read(file || self.filename)) rescue nil
      STDERR.puts "Configs not found (tried '#{file}' and '#{self.filename}')" if !@configs
      @configs
    end

    def check_target
      return if !@target || !@configs

      if !@configs[@target]
        STDERR.puts "Target #{@target} not found." 
        exit(1)
      end

      @configs = @configs[@target] 
      STDOUT.puts "Loaded #{@target} target."
    end

    def check_default_target
      if !@target && @configs && @configs["default"]
        STDOUT.puts "Loading default target ..."
        @configs = @configs["default"]
      end
    end
  end
end
