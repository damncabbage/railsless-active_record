require 'spec_helper'

describe Railsless::ActiveRecord::Config do
  let(:config) do
    described_class.new.tap do |c|
      c.root = fixture('app_with_paths')
    end
  end

  describe "#env" do
    it "uses RACK_ENV, SINATRA_ENV, RAILS_ENV or ENV to determine environment" do
      %w(RACK_ENV SINATRA_ENV RAILS_ENV ENV).each do |key|
        with_blank_env do
          ENV[key] = rand(1..999999).to_s
          expect(config.env).to eq ENV[key]
        end
      end
    end
    it "defaults to 'development'" do
      with_blank_env { expect(config.env).to eq 'development' }
    end
  end

  describe "#db_config" do
    let(:config_without_file) do
      described_class.new.tap do |c|
        c.root = fixture('find_root_with_flag')
      end
    end

    it "uses a database config if it's present" do
      expect(config.db_config).to eq({
        'development' => {
          'adapter'  => 'sqlite3',
          'database' => 'db/development.sqlite3',
          'pool'     => 5,
          'timeout'  => 5000,
        },
      })
    end
    it "falls back to ENV['DATABASE_URL'] if no database config can be found" do
      with_blank_env do
        ENV['DATABASE_URL'] = 'sqlite3:///db/development.sqlite3'
        expect(config_without_file.db_config).to eq ENV['DATABASE_URL']
      end
    end
    it "explodes is neither config nor ENV['DATABASE_URL'] is present" do
      with_blank_env do
        expect { config_without_file.db_config }.to raise_error
      end
    end
  end

  it "has sensible defaults for the rest" do
    expect(config.db_config_path).to eq File.join(config.root, 'config/database.yml')
    expect(config.seeds_path).to eq File.join(config.root, 'db/seeds.rb')
    expect(config.schema_path).to eq File.join(config.root, 'db/schema.rb')
    expect(config.migrations_path).to eq File.join(config.root, 'db/migrate')
    expect(config.logger).to be_a(Logger)
  end

  # Helpers

  def with_blank_env(&block)
    original = ENV
    ENV.replace({})
    yield if block_given?
    ENV.replace(original)
  end
end
