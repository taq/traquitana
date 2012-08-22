require "fileutils"
require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Packager do
   before do
      @packager = Traquitana::Packager.new(File.expand_path(File.dirname(__FILE__))+"/config/")
   end

   it "should have an id method" do
      @packager.must_respond_to(:id)
   end

   it "should return an id" do
      @packager.id.wont_be_nil
   end

   it "should have a list file method" do
      @packager.must_respond_to(:list_file)
   end

   it "should return the correct list file name" do
      id = @packager.id
      @packager.list_file.must_equal @packager.id+".list"
   end

   it "should have a zip file method" do
      @packager.must_respond_to(:zip_file)
   end

   it "should return the correct zip file name" do
      id = @packager.id
      @packager.zip_file.must_equal @packager.id+".zip"
   end

   it "should have a pack method" do
      @packager.must_respond_to(:pack)
   end

   it "should return the list and package file" do
      list, package = @packager.pack
   end
end

