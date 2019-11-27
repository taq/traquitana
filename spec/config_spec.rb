require 'yaml'
require 'fileutils'
require 'minitest/autorun'
require 'minitest/focus'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Config do
  before do
    @config = Traquitana::Config.instance
  end

  describe 'paths' do
    it 'should have a filename getter method' do
      expect(@config).must_respond_to :filename
    end

    it 'should have a filename called traq.yml if file name is not set' do
      expect(File.basename(@config.filename)).must_equal('traq.yml')
    end

    it 'should have a filename setter method' do
      expect(@config).must_respond_to :filename=
    end

    it 'should have a custom filename if filename is set' do
      old    = @config.filename
      custom = 'config/custom.yml'

      @config.filename = custom
      expect(@config.filename).must_equal custom
      @config.filename = old
    end

    it 'should have a default file method' do
      expect(@config).must_respond_to :default
    end

    it 'should have a valid directory' do
      expect(@config.directory).wont_be_nil
      expect(@config.directory.size > 0).must_equal true
    end
  end

  describe 'configs' do
    it 'should respond to configuration dynamic methods' do
      expect(@config.banana).must_equal ''
    end

    it 'should respond with the correct value' do
      @config.load
      expect(@config.user).must_equal 'taq'
    end

    it 'should have basic information on the default file' do
      contents = YAML.load(File.read(@config.default))
      expect(contents['directory']).wont_be_nil
      expect(contents['server']).wont_be_nil
      expect(contents['list']).wont_be_nil
      expect(contents['host']).wont_be_nil
    end
  end

  describe 'setup' do
    it 'should have a method named setup' do
      expect(@config).must_respond_to :setup
    end

    it 'should do nothing if the configuration file exists' do
      expect(@config.setup).must_equal false
    end

    it 'should write the configuration file if it doesnt exists' do
      contents = File.read(@config.filename)
      File.unlink(@config.filename)

      expect(File.exists?(@config.filename)).must_equal false
      expect(@config.setup).must_equal true
      expect(File.exists?(@config.filename)).must_equal true

      File.open(@config.filename, 'w') do |file| 
        file << contents
      end
    end
  end

  describe 'targets' do
    it 'should have a target readable attribute' do
      expect(@config).must_respond_to :target
    end

    it 'should have a target writable attribute' do
      expect(@config).must_respond_to :target=
    end

    it 'should load custom target config' do
      begin
        @config.filename = 'config/custom.yml'
        @config.target   = 'custom'
        @config.load
        expect(@config.directory).must_equal '/tmp/traq_test_custom'
      ensure
        reset_config
      end
    end
  end

  private

  def reset_config
    @config.filename = 'config/traq.yml'
    @config.target   = nil
    @config.load
  end
end
