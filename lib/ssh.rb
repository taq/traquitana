require "net/scp"
require "net/ssh"

module Traquitana
   class SSH
      attr_reader :host, :user, :options

      def initialize(host,user,options=nil)
         @host    = host
         @user    = user
         @options = options || {}
			STDOUT.puts "Connecting to #{@host} using user #{@user}"
      end

      def execute(cmds,verbose=false)
         rst = []
         Net::SSH.start(@host,@user,@options) do |ssh|
            for cmd in cmds
               STDOUT.puts "Executing #{cmd} on remote host ..." if verbose
               rst << ssh.exec!(cmd)
            end
         end
         rst
      end

      def send_files(col,updater=nil)
			Net::SCP.start(@host,@user,@options) do |scp|
            for files in col
               from, to = *files
               next if from.nil? || to.nil?
               scp.upload!(from,to) do |ch,name,sent,total|
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
