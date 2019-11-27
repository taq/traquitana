require 'fileutils'
require 'minitest/autorun'
require 'minitest/focus'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Packager do
  before do
    @packager = Traquitana::Packager.new(File.expand_path(File.dirname(__FILE__)) + '/config/')
  end

  it 'should have an id method' do
    expect(@packager).must_respond_to :id
  end

  it 'should return an id' do
    expect(@packager.id).wont_be_nil
  end

  it 'should have a list file method' do
    expect(@packager).must_respond_to :list_file
  end

  it 'should return the correct list file name' do
    expect(@packager.list_file).must_equal @packager.id + '.list'
  end

  it 'should have a zip file method' do
    expect(@packager).must_respond_to :zip_file
  end

  it 'should return the correct zip file name' do
    expect(@packager.zip_file).must_equal @packager.id + '.zip'
  end

  it 'should have a pack method' do
    expect(@packager).must_respond_to :pack
  end

  it 'should return the list and package file' do
    list, package = @packager.pack
    expect(list).wont_be_nil
    expect(package).wont_be_nil
  end
end
