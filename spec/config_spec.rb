require "yaml"
require "fileutils"
require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Config do
   before do
      @config = Traquitana::Config.instance
   end

   describe "paths" do
      it "should have a filename getter method" do
         @config.must_respond_to(:filename)   
      end

      it "should have a filename called traq.yml if file name is not set" do
         File.basename(@config.filename).must_equal("traq.yml")
      end

      it "should have a filename setter method" do
         @config.must_respond_to(:filename=)
      end

      it "should have a custom filename if filename is set" do
         old    = @config.filename
         custom = "config/custom.yml"
         @config.filename = custom
         @config.filename.must_equal custom
         @config.filename = old
      end

      it "should have a default file method" do
         @config.must_respond_to(:default)
      end
   end

   describe "configs" do
      it "should respond to configuration dynamic methods" do
         @config.banana.must_equal ""
      end

      it "should respond with the correct value" do
         @config.load
         @config.user.must_equal "taq"
      end

      it "should have basic information on the default file" do
         contents = YAML.load(File.read(@config.default))
         contents["directory"].wont_be_nil
         contents["server"].wont_be_nil
         contents["list"].wont_be_nil
         contents["host"].wont_be_nil
      end
   end

   describe "setup" do
      it "should have a method named setup" do
         @config.must_respond_to(:setup)
      end

      it "should do nothing if the configuration file exists" do
         @config.setup.must_equal false
      end

      it "should write the configuration file if it doesn't exists" do
         contents = File.read(@config.filename)
         File.unlink(@config.filename)

         assert !File.exists?(@config.filename)
         @config.setup.must_equal true
         assert File.exists?(@config.filename)

         File.open(@config.filename,"w") {|file| file << contents}
      end
   end
end
