require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Cleaner do
   before do
      @cleaner = Traquitana::Cleaner.new 
      @config  = Traquitana::Config.instance
      @config.load
   end

   it "should have a run method" do
      @cleaner.must_respond_to :run  
   end

   it "should run cleaner on remote host" do
      network = MiniTest::Mock.new
      network.expect(:execute,nil,[["find #{@config.directory}/traq -type f -iname '*.zip' -o -iname '*.list' | sort | head -n-2 | xargs rm $1"]])
      @cleaner.network = network
      @cleaner.run
      network.verify
   end
end
