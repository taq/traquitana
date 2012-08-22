require "minitest/autorun"
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Migrator do
   before do
      @migrator = Traquitana::Migrator.new

      @old_file = "#{File.expand_path(File.dirname(__FILE__))}/../traq/config.yml"
      @old_cont = File.read(@old_file)

      @new_file = "#{File.expand_path(File.dirname(__FILE__))}/../config/traq.yml"
      @new_cont = File.read(@new_file)

      File.unlink(@new_file)
   end

   after do
      FileUtils.mkdir(File.dirname(@old_file)) if !Dir.exists?(File.dirname(@old_file))
      FileUtils.mkdir(File.dirname(@new_file)) if !Dir.exists?(File.dirname(@new_file))

      File.open(@new_file,"w") {|f| f<<@new_cont}
      File.open(@old_file,"w") {|f| f<<@old_cont}
   end

   it "should have a run method" do
      @migrator.must_respond_to(:run)
   end
   
   it "should return false when there isn't an old config file" do
      contents = File.read(@old_file)
      File.unlink(@old_file)
      assert !@migrator.run
      File.open(@old_file,"w") {|f| f<<contents}         
   end

   it "should return false if there is a new config file" do
      File.open(@new_file,"w") {|f| f<<@new_cont}
      assert !@migrator.run
   end

   it "should return true when there is an old config file" do
      assert @migrator.run
   end

   it "should have the new file after run" do
      File.unlink(@new_file) if File.exists?(@new_file)
      @migrator.run
      assert File.exists?(@new_file)
   end

   it "should not have the old file after run" do
      @migrator.run
      assert !File.exists?(@old_file)
   end

   it "should not have the old dir after run" do
      @migrator.run
      assert !Dir.exists?(File.dirname(@old_file))
   end

   it "should not have the ignore clause on the new file" do
      @migrator.run
      assert !YAML.load(File.read(@new_file)).include?("ignore")
   end

   it "should have all the keys of the old file on the new one" do
      old_content = YAML.load(File.read(@old_file)).reject {|k,v| k==:ignore}
      @migrator.run
      new_content = YAML.load(File.read(@new_file))
      old_content.each do |key,val|
         assert new_content.include?(key.to_s)
         assert new_content[key.to_s].to_s==old_content[key].to_s
      end
   end
end
