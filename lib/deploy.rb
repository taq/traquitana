module Traquitana
	class Deploy
		TRAQ_VERSION="0.0.9"

		def initialize
			@config	= Traquitana::Config.instance
			@progress = -1
		end			

		def section_msg(msg)
			puts "\n#{msg}"
			puts "#{'-'*msg.size}\n"
		end

		def setup
			puts "Running setup"
			if !File.exist?(@config.dir)
				Dir.mkdir(@config.dir)
			end
			puts "Writing #{@config.config}"
			File.open(@config.config,"w") do |file|
				file << "# Default configuration"
				file << File.read(@config.default)
			end
			puts "Setup completed!"
			puts "You MUST check the configurations on #{@config.config} before deploying!"
			exit 1
		end

		def show_bar(name,sent,total)
			bt, bp = 20, 5
			return if sent<=0 

			prop = sent > 0 ? ((100/(total/sent.to_f))/bp).to_i : 0
			return if prop<=0 

			if prop != @progress
				bar = Array.new(bt,"-")
				bar[0...prop] = Array.new(prop,"*")
				name = File.basename(name).ljust(20)
				STDOUT.print "Sending #{name} #{(prop*bp).to_s.rjust(3)}% : #{bar.join}\r"
				STDOUT.flush
				@progress = prop
			end				
			if sent==total
				puts "\n#{name.strip} sent.\n"
				@progress = -1
			end
		end

		def upload(scp,from,to)
			puts " "
			scp.upload!(from,to) do |ch,name,sent,total|
				show_bar(name,sent,total)
			end
		end

		def run
			if !File.exist?(@config.config)
				STDERR.puts "No config file (#{@config.config}) found."	
				STDERR.puts "Did you run traq setup?"
				STDERR.puts "Run it and check the configuration before deploying."
				exit 1
			end
			@config.load
         @shell = @config.shell ? "#{@config.shell} " : ""

			puts "Running Traquitana version #{TRAQ_VERSION}\n"
			puts "Connecting to #{@config.host} with #{@config.user}, sending files to #{@config.directory}"
			section_msg("Checking changed files on the last #{@config.ignore} hour(s)")
			all_list = []

			for files in @config.list
				send, ignore = files
				puts "Will send #{send}"+(ignore ? " and ignore #{ignore}" : "")
				send_list = Dir.glob(send)
				next if send_list.size<1
				if ignore
					ignore_list	= Dir.glob(ignore)
				end		
				result = ignore_list ? send_list - ignore_list : send_list
				result = result.select {|item| f = File.new(item); !File.directory?(item) && (Time.now-f.mtime)/3600 <= @config.ignore }
				all_list.push(*result)
			end

			if all_list.size < 1
				puts "\nNo files changed on the last #{@config.ignore} hour(s)."
				exit 1
			end

			# current id and files
			id = Time.now.to_f.to_s.sub(/\./,"")
			all_list_file	= "#{id}.list"
			all_list_zip	= "#{id}.zip"

			# first time running? send database.yml also
			first_run_file = "traq/.first_run"
			if Dir.glob(first_run_file).size<1
				puts "Will send config/database.yml"
				all_list << "config/database.yml" 
				FileUtils.touch(first_run_file)
			end

			File.open(all_list_file,"w") {|file| file << all_list.join("\n")}
			section_msg("File list created")

			section_msg("Creating ZIP file with #{all_list.size} files")
			File.unlink(all_list_zip) if File.exist?(all_list_zip)
			Zip::ZipFile.open(all_list_zip,true) do |zipfile|
				all_list.each do |file|
					puts "Adding #{file} ..."
					zipfile.add(file,file)	
				end
			end
			puts "ZIP file created."

			section_msg("Sending list, ZIP file and control files to remote host")
			migrate = all_list.find {|item| item =~ /db\/migrate/}
			options = @config.password.size>1 ? {:password=>@config.password} : {}
				
			# check if the traq directory exists 
			Net::SSH.start(@config.host,@config.user,options) do |ssh|
				ssh.exec!("mkdir -p #{@config.directory}/traq")
			end

			Net::SCP.start(@config.host,@config.user,options) do |scp|
				upload(scp,"#{File.dirname(File.expand_path(__FILE__))}/../config/proc.sh","#{@config.directory}/traq/proc.sh")
				upload(scp,"#{File.dirname(File.expand_path(__FILE__))}/../config/#{@config.server}.sh","#{@config.directory}/traq/server.sh")
				upload(scp,all_list_file,"#{@config.directory}/traq/#{all_list_file}")
				upload(scp,all_list_zip ,"#{@config.directory}/traq/#{all_list_zip}")
			end
			section_msg("Running processes on the remote server")

			Net::SSH.start(@config.host,@config.user,options) do |ssh|
				result = ""
				puts "executing: #{@shell}#{@config.directory}/traq/proc.sh #{@config.directory}/traq #{all_list_file.split(File.extname(all_list_file)).first}"
				ssh.exec!("#{@shell}#{@config.directory}/traq/proc.sh #{@config.directory}/traq #{all_list_file.split(File.extname(all_list_file)).first}") do |channel, stream, data|
					result << data
				 end
				 puts result
			end
			puts "\nDone. Have fun.\n"

			# clean up
			File.unlink(all_list_file)
			File.unlink(all_list_zip)
		end
	end
end
