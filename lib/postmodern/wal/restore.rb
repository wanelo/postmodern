require_relative 'archive'

module Postmodern
  module WAL
    class Restore < Archive
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

