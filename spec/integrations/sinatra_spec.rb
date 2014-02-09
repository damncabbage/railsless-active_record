require 'spec_helper'
require 'fileutils'
require 'net/http'
require 'open3'
require 'json'

# The following tests spin up a Sinatra app in a separate process; keeping it
# isolated means we can test the entire DB and app lifecycle without risk of pollution.

# This shared example is used by both the spec/apps/sinatra-modular and
# spec/apps/sinatra-classic dummy apps. The meat of the specs are in the example;
# see the bottom of file for app definitions. (We need to define the shared example
# before we can use it.)
shared_examples "a Sinatra app" do
  before(:all) { run "bundle install" }

  it "prints the expected list of ActiveRecord Rake tasks" do
    out = run "bundle exec rake -T"
    %w(
      create drop fixtures:load migrate migrate:status rollback
      schema:cache:clear schema:cache:dump schema:dump schema:load
      seed setup structure:dump version
      generate:config generate:migration
    ).each do |task|
      expect(out).to match /^rake db:#{task}/
    end
  end

  context "generators" do
    describe "db:generate:config" do
      let(:config_path) do
        File.join(app_path, 'config/database.yml')
      end
      let(:template_path) do
        File.expand_path('../../templates/database.yml', File.dirname(__FILE__))
      end

      it "ignores an existing config file" do
        expect(File).to exist(config_path)
        out = run "bundle exec rake db:generate:config"
        expect(out).to match /Database config already exists/
      end

      it "generates a config file that doesn't yet exist" do
        FileUtils.rm_f(config_path)
        out = run "bundle exec rake db:generate:config"
        expect(File.read(config_path)).to eq File.read(template_path)
      end

      # Force a reset of the configuration, regardless of the test results.
      after do
        FileUtils.rm_f(config_path)
        FileUtils.cp(template_path, config_path)
      end
    end

    pending "'db:generate:migration NAME=NameHere' creates a migration" do
      # TODO: 'NameHere' -> 'name_here' transform.
    end
  end

  context "requests" do
    # HACK: rackup doesn't allow "-p 0" for binding to a free non-privileged port.
    #       Suggested terrible, race-conditioney alternative:
    #         s = TCPServer.new('127.0.0.1', 0); port = s.addr[1]; s.close
    let(:port) { rand(10_000..10_999) }
    let(:host) { 'localhost' }

    it "serves database-backed requests" do
      run "bundle exec rake db:drop db:create db:migrate"
      run_while "bundle exec rackup -p #{port}" do |stdout_and_err|
        # Wait for Sinatra to show up; explode if it doesn't.
        wait_for_port! host, port, 3 # seconds

        uri = URI("http://#{host}:#{port}/messages")
        expect(JSON.parse(Net::HTTP.get(uri))).to eq []

        post = JSON.parse(Net::HTTP.post_form(uri, 'title' => "Hello World").body)
        expect(post['title']).to eq "Hello World"

        posts = JSON.parse(Net::HTTP.get(uri))
        expect(posts.count).to eq 1
        expect(posts[0]['title']).to eq post['title']
      end
    end
  end

  # Helpers

  def run(command)
    output = ""
    Bundler.with_clean_env do
      output, status = Open3.capture2(command, :chdir => app_path)
      expect(status).to be_success
    end
    output
  end

  def run_while(command, &block)
    Bundler.with_clean_env do
      Open3.popen2e(command, :chdir => app_path) do |stdin, stdout_and_err, wait_thr|
        pid = wait_thr.pid
        begin
          yield(stdout_and_err) if block_given?
        ensure
          Process.kill('TERM', pid)
        end
      end
    end
  end

  # Waits until a port is open; raise InlineTimeout::Error if times out.
  def wait_for_port!(host, port, seconds, interval=0.5)
    InlineTimeout.timeout(seconds, interval) do
      begin
        TCPSocket.new(host, port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        false
      end
    end
  end
end

# Example require('sinatra/base'), class-based Sinatra app.
describe "Sinatra 'Modular' Integration" do
  def app_path
    File.expand_path('../apps/sinatra-modular', File.dirname(__FILE__))
  end
  it_behaves_like "a Sinatra app"
end

# Example require('sinatra'), base-DSL-using Sinatra app.
describe "Sinatra 'Classic' Integration" do
  def app_path
    File.expand_path('../apps/sinatra-classic', File.dirname(__FILE__))
  end
  it_behaves_like "a Sinatra app"
end
