# frozen_string_literal: true

require 'yaml'
require 'fileutils'
require 'minitest/autorun'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/traquitana.rb"

describe Traquitana::Deployer do
  before do
    @config = Traquitana::Config.instance
    @deploy = Traquitana::Deployer.new(verbose: true)
  end

  it 'deploys' do
    @deploy.run
  end
end
