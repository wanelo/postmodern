module Postmodern
  module WAL
    class Base
      attr_reader :filename, :path

      def initialize(filename, path)
        @filename = filename
        @path = path
      end

      def run
        if local_script_exists?
          IO.popen("#{local_script} #{path} #{filename}",
            env: {
              'WAL_ARCHIVE_PATH' => path,
              'WAL_ARCHIVE_FILE' => filename,
              'PATH' => ENV['PATH']
            })
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
    end
  end
end
