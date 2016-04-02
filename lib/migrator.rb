require "yaml"

module Traquitana
  class Migrator
    def run
      old_file = "./traq/config.yml"
      new_file = "./config/traq.yml"

      return false if !File.exists?(old_file) || File.exists?(new_file)

      STDOUT.puts "Migrating old config file ..."
      contents = YAML.load(File.read(old_file))
      contents = contents.inject({}) {|hash,val| hash[val.first.to_s] = val.last; hash}.reject { |k,v| k == "ignore"}.to_yaml
      File.open(new_file, "w") { |f| f << contents }

      File.unlink(old_file)
      first_run = "#{File.dirname(old_file)}/.first_run"
      File.unlink(first_run) if File.exists?(first_run)

      dir = "#{File.dirname(old_file)}"
      Dir.unlink(dir) if Dir.exists?(dir)
      true
    end
  end
end
