require "fileutils"
require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Selector do
   it "should have a selected files method" do
      Traquitana::Selector.new.must_respond_to(:files)
   end

   it "should return the file list" do
      list = Traquitana::Selector.new(File.expand_path(File.dirname(__FILE__))+"/config/").files
      list.size.must_equal 23
   end
end
