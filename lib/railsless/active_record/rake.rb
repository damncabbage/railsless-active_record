require 'active_support/inflector' # Doesn't mix in; called for its class methods.
require 'active_record'
require 'fileutils'
require 'rake'
require 'erb'

module Railsless
  module ActiveRecord
    module Rake
      module_function

      TEMPLATES_PATH = File.expand_path('../../../templates', File.dirname(__FILE__))

      def load_tasks!(config=nil)
        config ||= Railsless::ActiveRecord::Config.new
        load_database_tasks!(config)
        load_generator_tasks!(config)
      end

      def load_database_tasks!(config)
        extend ::Rake::DSL

        # ActiveRecord looks to db:load_config for its DatabaseTasks setup.
        # Load it up with our own configuration first.
        namespace :db do
          task :load_config do
            ::ActiveRecord::Tasks::DatabaseTasks.root = config.root
            ::ActiveRecord::Tasks::DatabaseTasks.env = config.env
            ::ActiveRecord::Tasks::DatabaseTasks.db_dir = config.db_path
            ::ActiveRecord::Tasks::DatabaseTasks.database_configuration = config.db_config
            ::ActiveRecord::Tasks::DatabaseTasks.migrations_paths = config.migrations_path
            ::ActiveRecord::Tasks::DatabaseTasks.seed_loader = SeedLoader.new(config.seeds_path)
            ::ActiveRecord::Tasks::DatabaseTasks.fixtures_path = nil # TODO
          end
        end

        # Stub out the :environment task that DatabaseTasks depends on.
        # Ideally, the app using this library loads the app from within an
        # :environment task (as per the README), but provide this as a fallback.
        unless ::Rake::Task.task_defined? :environment
          task :environment
        end

        load 'active_record/railties/databases.rake'
      end

      # Creates database.yml files and migrations.
      def load_generator_tasks!(config)
        extend ::Rake::DSL
        namespace :db do
          namespace :generate do

            desc "Generate and write a config/database.yml"
            task :config do
              db_config_path = config.db_config_path
              if File.exists?(db_config_path)
                puts "Database config already exists at #{db_config_path}; skipping..."
              else
                FileUtils.mkdir_p(config.config_path)
                FileUtils.cp(File.join(TEMPLATES_PATH, 'database.yml'), db_config_path)
              end
            end

            desc "Generate a database migration, eg: rake db:generate:migration NAME=CreatePosts"
            task :migration do
              migrations_path = config.migrations_path
              timestamp = Time.now.strftime("%Y%m%d%H%M%S")
              name = ENV.fetch('NAME') do
                fail "Usage: rake db:generate:migration NAME=CreatePosts"
              end

              # Normalise the name to a MigrationClass and a migration_filename
              migration_class    = ActiveSupport::Inflector.camelize(name)
              migration_filename = "#{timestamp}_#{ActiveSupport::Inflector.underscore(name)}.rb"
              migration_path     = File.join(migrations_path, migration_filename)

              template = File.read(File.join(TEMPLATES_PATH, 'migration.erb'))
              FileUtils.mkdir_p(migrations_path)
              File.write(migration_path, ERB.new(template).result(binding))

              puts "Created migration: #{migration_path}"
            end
          end
        end
      end
    end
  end
end
