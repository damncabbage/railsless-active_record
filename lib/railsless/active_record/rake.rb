require 'active_record'
require 'rake'

module Railsless
  module ActiveRecord
    module Rake
      module_function

      def load_tasks!(config=nil)
        config ||= Railsless::ActiveRecord::Config.new
        load_database_tasks!(config)
        load_migration_task!(config)
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

      def load_migration_task!(config)
        extend ::Rake::DSL
        # TODO: rake db:create_migration NAME=...
      end
    end
  end
end
