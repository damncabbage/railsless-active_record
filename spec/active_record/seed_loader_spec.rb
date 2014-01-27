require 'spec_helper'

describe Railsless::ActiveRecord::SeedLoader do
  let(:seed_path) { fixture('seeds.rb') }
  let(:bad_seed_path) { fixture('doesnt_exist.rb') }
  before { stub_const('BlogPost', double) }

  it "loads a seed file that exists" do
    loader = Railsless::ActiveRecord::SeedLoader.new(seed_path)
    expect(BlogPost).to receive(:create).with(:title => "Example")
    loader.load_seed
  end

  it "ignores non-existent seeds" do
    [bad_seed_path, nil].each do |path|
      loader = Railsless::ActiveRecord::SeedLoader.new(path)
      expect(BlogPost).to_not receive(:create)
      expect(loader.load_seed).to be_nil
    end
  end
end
