require 'spec_helper'

describe Railsless::ActiveRecord::Root do
  let(:root) { described_class }

  describe ".calculate" do
    it "uses config.ru and the current working dir to find the app root" do
      dir = fixture('find_root_with_flag')
      expect(Dir).to receive(:pwd).and_return(dir)
      expect(root.calculate).to eq dir
    end
  end

  describe ".to eq dir.find_root_with_flag" do
    it "finds a flag file in the starting directory (eg. current working dir)" do
      starting = fixture('find_root_with_flag')
      expect(root.find_root_with_flag('config.ru', starting)).to eq starting
    end

    it "looks up the tree until it finds the flag file" do
      dir      = fixture('find_root_with_flag')
      starting = File.join(dir, 'bin') # find_root_with_flag/bin
      expect(root.find_root_with_flag('config.ru', starting)).to eq dir
    end

    # If this test explodes on your machine, it probably means you have a
    # config.ru hanging around in a parent directory. :)
    it "explodes when it can't find the flag file" do
      starting = File.dirname(__FILE__)
      expect {
        root.find_root_with_flag('config.ru', starting)
      }.to raise_error(StandardError, "Could not find root path for hosting application")
    end
  end
end
