require "net/scp"
require "net/ssh"
require "highline/import"

module Traquitana
   class SSH
      attr_reader :host, :user, :options

      def initialize(host, user, options = nil)
         @host    = host
         @user    = user
         @options = options || {}
         @options[:verbose] = :error
         STDOUT.puts "Connecting to \e[1m#{@host}\e[0m using user \e[1m#{@user}\e[0m"
      end

      def execute(cmds,verbose=false)
        rst = []

        Net::SSH.start(@host,@user,@options) do |ssh|
          ssh.open_channel do |channel|
            channel.request_pty do |ch, success|
              raise "Can't get PTY" unless success
              for cmd in cmds
                STDOUT.puts "Executing #{cmd} on remote host ..." if verbose
                rst << ch.exec(cmd)
              end # for

              ch.on_data do |chd, data|
                msg = data.inspect.to_s.gsub(/^"/,"").gsub(/"$/,"").gsub(/"\\"/,"\\").gsub("\\r","").gsub("\\n","\n").gsub("\\e","\e").strip.chomp
                if data.inspect =~ /sudo/
                  pwd = ask("\nNeed password to run as root/sudo: ") { |c| c.echo = "*" }
                  channel.send_data("#{pwd}\n")
                  sleep 0.1
                else
                  STDOUT.puts msg if msg.size > 1
                end
                chd.wait
              end
            end # tty
          end # channel
          ssh.loop
        end # ssh start
        rst
      end

      def send_files(col,updater=nil)
        Net::SCP.start(@host, @user, @options) do |scp|
            for files in col
               from, to = *files
               next if from.nil? || to.nil?
               scp.upload!(from,to) do |ch, name, sent, total|
                  if !updater.nil?
                     updater.name  = to
                     updater.total = total
                     updater.update(sent)
                  end
               end
               updater.reset if !updater.nil?
            end
         end
      end
   end
end
