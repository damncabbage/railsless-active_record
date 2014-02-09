# Partially inspired by railties-4.0.0/lib/rails/engine.rb
# In essence, it's:
# - Picking a file to look for (eg. config.ru),
# - Starting at an arbitrary directory (eg. the current working directory), and then
# - Traversing back up the directory tree until it either finds a flag file, or hits
#   the root folder.

module Railsless
  module ActiveRecord
    class Root
      def self.calculate(flag_file=nil, start_from=nil)
        find_root_with_flag(
          flag_file  || 'config.ru', # Look for something signifying Rack. Not much else to go on.
          start_from || Dir.pwd # Yes, Rails does this.
        )
      end

      # Starts from a directory, and works upwards looking for a particular file.
      def self.find_root_with_flag(flag, starting_path)
        # This process if only useful if the starting_path is an absolute path.
        path = if starting_path[0] == '/'
                 starting_path
               else
                 File.absolute_path(starting_path) # Relative; turn into absolute path
               end

        while path && File.directory?(path) && !File.exist?("#{path}/#{flag}")
          parent = File.dirname(path)
          path = (parent != path) && parent
        end

        if path && File.exist?("#{path}/#{flag}")
          File.realpath path
        else
          raise "Could not find root path for hosting application"
        end
      end
    end
  end
end


