module Railsless
  module ActiveRecord
    class SeedLoader
      attr_accessor :path
      def initialize(path)
        @path = path
      end

      def load_seed
        Kernel.load(path) if path && File.exist?(path)
      end
    end
  end
end
