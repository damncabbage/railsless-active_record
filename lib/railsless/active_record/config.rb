require 'railsless/active_record/root'
require 'logger'
require 'yaml'
require 'erb'

module Railsless
  module ActiveRecord
    class Config
      def self.attr_accessor_with_default(name, &block)
        module_eval do
          attr_writer name
          define_method(name) do
            # Don't cache the result; if you really needs to, define a method manually.
            instance_variable_get(:"@#{name}") || instance_exec(&block)
          end
        end
      end

      def initialize(overrides={})
        overrides.each { |attr,val| send(:"#{attr}=", val) }
      end

      # An overblown way of figuring out where the calling application's root
      # is, borrowed from Rails.
      attr_writer :root
      def root
         @root ||= Root.calculate
      end

      # Fumble around picking the right running environment.
      attr_accessor_with_default(:env) do
        ENV['RACK_ENV'] || ENV['SINATRA_ENV'] || ENV['RAILS_ENV'] || ENV['ENV'] || 'development'
      end

      attr_accessor_with_default(:db_config) do
        YAML.load(read_config(db_config_path)).with_indifferent_access
      end
      attr_accessor_with_default(:db_config_path) do
        File.join(root, 'config', 'database.yml')
      end
      attr_accessor_with_default(:db_path)     { File.join(root, 'db') }
      attr_accessor_with_default(:seeds_path)  { File.join(db_path, 'seeds.rb') }
      attr_accessor_with_default(:schema_path) { File.join(db_path, 'schema.rb') }
      attr_accessor_with_default(:migrations_path) { File.join(db_path, 'migrate') }

      attr_accessor_with_default(:logger) { Logger.new(STDOUT) }

      protected

        # Intentionally explodes violently if the file doesn't exist.
        def read_config(filename)
          ERB.new(File.read(filename)).result
        end
    end
  end
end

