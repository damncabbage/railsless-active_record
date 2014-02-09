require 'railsless/active_record/version'
require 'railsless/active_record/config'
require 'railsless/active_record/seed_loader'
require 'railsless/active_record/rake'
require 'active_record'

module Railsless
  module ActiveRecord
    module_function

    def connect!(config)
      db_config = config.db_config
      if db_config.is_a?(String)
        ::ActiveRecord::Base.establish_connection(db_config)
      else
        ::ActiveRecord::Base.configurations = db_config
        ::ActiveRecord::Base.establish_connection(config.env)
      end
      ::ActiveRecord::Base.logger = config.logger
      ::ActiveRecord::Base
    end

    def disconnect!
      ::ActiveRecord::Base.clear_active_connections!
    end
  end
end
