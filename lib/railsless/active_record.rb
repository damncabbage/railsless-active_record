require 'railsless/active_record/version'
require 'railsless/active_record/config'
require 'railsless/active_record/seed_loader'
require 'railsless/active_record/rake'
require 'active_record'

module Railsless
  module ActiveRecord
    module_function

    def connect!(config)
      ::ActiveRecord::Base.logger = config.logger
      ::ActiveRecord::Base.configurations = config.db_config
      ::ActiveRecord::Base.establish_connection(config.env)
      ::ActiveRecord::Base
    end

    def disconnect!
      ::ActiveRecord::Base.clear_active_connections!
    end
  end
end
