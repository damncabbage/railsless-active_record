# Very heavily inspired by railties-4.0.0/lib/rails/engine.rb
# Despite replicating the Rails logic, this is really goddamn confusing.
# TODO: Refactor.
# In essence, it's:
# - Checking for a flag file (config.ru)
# - Traversing back up the dir tree if the path is absolute (File.dirname(".") just produces ".",
#   so therefore, say... 'bin' just reduces down to '.' as well.
# - Falling back to a default directory, usually Dir.pwd.

module Railsless
  module ActiveRecord
    class Root
      def self.calculate(flag_file=nil, start_from=nil)
        find_root_with_flag(
          flag_file  || 'config.ru', # Look for something signifying Rack. Not much else to go on.
          start_from || Dir.pwd # Yes, Rails does this.
        )
      end

      def self.find_root_with_flag(flag, default_root=nil, starting_path=nil)
        starting_path = default_root #||= called_from

        root = if starting_path[0] == '/'
                 # This process if only useful if the starting_path is an absolute path.
                 while starting_path && File.directory?(starting_path) && !File.exist?("#{starting_path}/#{flag}")
                   parent = File.dirname(starting_path)
                   starting_path = parent != starting_path && parent
                 end
                 starting_path
               else
                 default_root
               end

        if File.exist?("#{root}/#{flag}")
          File.realpath root
        else
          raise "Could not find root path for hosting application"
        end
      end

      def self.called_from
        @called_from ||= begin
          # Use explicit Kernel references so we can stub them for tests.
          call_stack = if Kernel.respond_to?(:caller_locations)
            Kernel.caller_locations.map(&:path) # 2.x
          else
            # Remove the line number from backtraces making sure we don't leave anything behind
            Kernel.caller.map { |p| p.sub(/:\d+.*/, '') } # 1.9
          end

          # Find the first filename in the call list that isn't part of this gem, eg.
          # - /home/me/.rbenv/.../railsless-active_record/lib/railsless/active_record.rb
          # - app.rb <== This one.
          File.dirname(call_stack.detect { |p| p !~ %r{railsless-active_record[\w.-]*/lib/railsless/active_record} })
        end
      end
    end
  end
end


