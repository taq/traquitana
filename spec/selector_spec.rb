require 'fileutils'
require 'minitest/autorun'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Selector do
  it 'should have a selected files method' do
    expect(Traquitana::Selector.new).must_respond_to :files
  end

  it 'should return the file list' do
    list = Traquitana::Selector.new(File.expand_path(File.dirname(__FILE__)) + '/config/').files
    expect(list.size).must_equal 29
  end
end
