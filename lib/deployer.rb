module Traquitana
  class Deployer
    def initialize(options=nil)
      @config          = Traquitana::Config.instance
      @verbose         = !options.nil? && options[:verbose]
      @config.filename = options[:filename] if options[:filename]
      @config.target   = options[:target]   if options[:target]
    end

    def run
      STDOUT.puts "\e[1mRunning Traquitana version #{VERSION}\e[0m\n\n"
      Traquitana::Migrator.new.run

      if !File.exist?(@config.filename)
        STDERR.puts "\e[31mNo config file (#{@config.filename}) found."	
        STDERR.puts "Did you run \e[1mtraq setup\e[0;31m ?"
        STDERR.puts "Run it and check the configuration before deploying.\e[0m"
        exit 1
      end

      @config.load

      @options = @config.password.size>1 ? {:password=>@config.password} : {}
      @server  = @config.server.to_s.size>0 ? @config.server : "none"
      @shell   = @config.shell ? "#{@config.shell} " : ""
      @network = Traquitana::SSH.new(@config.host,@config.user,@options)

      @packager = Traquitana::Packager.new
      @packager.verbose = @verbose
      all_list_file, all_list_zip = @packager.pack
      if !File.exists?(all_list_file) ||
        !File.exists?(all_list_zip)
        STDERR.puts "\e[31mCould not create the needed files.\e[0m"
        exit 2
      end

      # check if the traq destination and config directories exists 
      @network.execute(["mkdir -p #{@config.directory}/traq"],@verbose)
      @updater = Traquitana::Bar.new

      STDOUT.puts "Sending files ..."
      @network.send_files([["#{File.dirname(File.expand_path(__FILE__))}/../config/proc.sh","#{@config.directory}/traq/proc.sh"],
                           ["#{File.dirname(File.expand_path(__FILE__))}/../config/#{@server}.sh","#{@config.directory}/traq/server.sh"],
      [all_list_file,"#{@config.directory}/traq/#{File.basename(all_list_file)}"],
      [all_list_zip ,"#{@config.directory}/traq/#{File.basename(all_list_zip)}"]],@updater)
      STDOUT.puts "\e[32mAll files sent.\e[0m\n\n"

      @network.execute(["chmod +x #{@config.directory}/traq/proc.sh"],@verbose)
      @network.execute(["chmod +x #{@config.directory}/traq/server.sh"],@verbose)

      cmd = "#{@config.directory}/traq/proc.sh #{@config.directory}/traq #{@packager.id} #{@verbose}"
      cmd = "#{@shell} \"#{cmd}\"" if @shell

      STDOUT.puts "Running remote update commands, please wait ..."
      STDOUT.puts @network.execute([cmd],@verbose).join

      # clean up
      File.unlink(all_list_file)
      File.unlink(all_list_zip)
      STDOUT.puts "\e[32mAll done. Have fun.\e[0m\n"
    end
  end
end
