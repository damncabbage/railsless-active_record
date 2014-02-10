require 'active_record'
require 'rake'
require 'fileutils'

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
              # TODO: NAME=...
              raise "Not Implemented"
            end
          end
        end
      end
    end
  end
end
