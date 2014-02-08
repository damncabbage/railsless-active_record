require 'railsless/active_record'

# HACK: Some internals of the ActiveRecord Rake tasks refer to Rails.root
#       directly. Define it here if necessary, and be careful about it.
unless defined?(Rails) && Rails.respond_to?(:root)
  module Rails
    def self.root
      Railsless::ActiveRecord::Config.new.root
    end
  end
end

Railsless::ActiveRecord::Rake.load_tasks!
