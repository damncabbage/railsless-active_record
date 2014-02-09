require 'railsless/active_record'

module Railsless
  module ActiveRecord
    module SinatraExtension

      def self.registered(app)
        unless app.respond_to?(:activerecord_config) && app.activerecord_config
          app.set :activerecord_config, Railsless::ActiveRecord::Config.new
        end
        app.set :database, app.database
        app.helpers SinatraExtensionHelper
        app.after { Railsless::ActiveRecord.disconnect! }
      end

      def database
        @database ||= Railsless::ActiveRecord.connect!(activerecord_config)
      end

      def activerecord_config=(config)
        @database = nil
        @activerecord_config = config
        @database = Railsless::ActiveRecord.connect!(config)
      end
    end

    module SinatraExtensionHelper
      def database
        settings.database
      end
    end
  end
end

# HACK: Support classic apps by automatically registering the extension, as recommended
#       by the Sinatra docs here: http://www.sinatrarb.com/extensions.html
if defined?(Sinatra) && defined?(Sinatra::Application)
  # We're using classic; sinatra/main defines Sinatra::Application, so hook into that.
  Sinatra::Application.send(:register, ::Railsless::ActiveRecord::SinatraExtension)
end
