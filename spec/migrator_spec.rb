require 'minitest/autorun'
require 'minitest/focus'
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
    FileUtils.mkdir(File.dirname(@old_file)) unless Dir.exists?(File.dirname(@old_file))
    FileUtils.mkdir(File.dirname(@new_file)) unless Dir.exists?(File.dirname(@new_file))

    File.open(@new_file, 'w') { |f| f << @new_cont }
    File.open(@old_file, 'w') { |f| f << @old_cont }
  end

  it 'should have a run method' do
    expect(@migrator).must_respond_to :run
  end

  it 'should return false when there isnt an old config file' do
    contents = File.read(@old_file)
    File.unlink(@old_file)

    expect(@migrator.run).must_equal false
    File.open(@old_file, 'w') { |f| f << contents }
  end

  it 'should return false if there is a new config file' do
    File.open(@new_file,"w") {|f| f<<@new_cont}
    expect(@migrator.run).must_equal false
  end

  it 'should return true when there is an old config file' do
    expect(@migrator.run).must_equal true
  end

  it 'should have the new file after run' do
    File.unlink(@new_file) if File.exists?(@new_file)
    @migrator.run
    expect(File.exists?(@new_file)).must_equal true
  end

  it 'should not have the old file after run' do
    @migrator.run
    expect(File.exist?(@old_file)).must_equal false
  end

  it 'should not have the old dir after run' do
    @migrator.run
    expect(Dir.exist?(File.dirname(@old_file))).must_equal false
  end

  it 'should not have the ignore clause on the new file' do
    @migrator.run
    expect(YAML.load(File.read(@new_file)).include?('ignore')).must_equal false
  end

  it 'should have all the keys of the old file on the new one' do
    old_content = YAML.load(File.read(@old_file)).reject { |k, v| k == :ignore }
    @migrator.run

    new_content = YAML.load(File.read(@new_file))
    old_content.each do |key, _|
      expect(new_content.include?(key.to_s)).must_equal true
      expect(new_content[key.to_s].to_s == old_content[key].to_s).must_equal true
    end
  end
end
