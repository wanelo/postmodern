module Postmodern
  module WAL
    class Base
      attr_reader :filename, :path

      def initialize(filename, path)
        @filename = filename
        @path = path

        ENV['WAL_ARCHIVE_PATH'] = path
        ENV['WAL_ARCHIVE_FILE'] = filename
      end

      def run
        if local_script_exists?
          log
          `#{local_script} #{path} #{filename}`
        end
      end

      private

      def local_script_exists?
        `which #{local_script} >/dev/null 2>/dev/null`
        $?.exitstatus == 0
      end

      def local_script
        'postmodern_archive.local'
      end

      def log
        puts "Archiving file: #{filename}, path: #{path}"
      end
    end
  end
end

