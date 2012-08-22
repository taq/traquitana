require "digest/md5"
require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::SSH do
   before do
      @config  = Traquitana::Config.instance
      @network = Traquitana::SSH.new(@config.host,@config.user)
      @send    = "#{File.expand_path(File.dirname(__FILE__))}/config/network_test.txt"
      @md5     = Digest::MD5.hexdigest(File.read(@send))

      Dir.mkdir(@config.directory) if !File.exists?(@config.directory)
   end

   describe "configs" do
      it "should have a host attribute" do
         @network.must_respond_to(:host)
      end

      it "should have an user attribute" do
         @network.must_respond_to(:user)
      end

      it "should have an options attribute" do
         @network.must_respond_to(:options)
      end
   end

   describe "operations" do
      it "should have a send method" do
         @network.must_respond_to(:send_files)
      end

      it "should send a file to the remote host" do
         check = "#{@config.directory}/#{File.basename(@send)}"
         File.unlink(check) if File.exists?(check) 
         @network.send_files([[@send,"#{@config.directory}/#{File.basename(@send)}"]],Traquitana::Bar.new)
         assert File.exists?(check)
         Digest::MD5.hexdigest(File.read(check)).must_equal @md5
      end

      it "should have a execute method" do
         @network.must_respond_to(:execute)
      end

      it "should execute a command on the remote host" do
         remote_dir = "#{@config.directory}/remote_dir"
         FileUtils.rmdir(remote_dir) if File.exists?(remote_dir)
         @network.execute(["mkdir #{@config.directory}/remote_dir"])
         assert File.exists?(remote_dir)
      end
   end

   describe "uploading" do
   end
end
