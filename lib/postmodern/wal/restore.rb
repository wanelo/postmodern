require_relative 'base'

module Postmodern
  module WAL
    class Restore < Base
      private

      def local_script
        'postmodern_restore.local'
      end
      
      def log
        puts "Restoring file: #{filename}, path: #{path}"
      end
    end
  end
end

