require 'postmodern/command'

module Postmodern
  module WAL
    class Archive < Postmodern::Command
      required_options << :file
      required_options << :path

      def parser
        @parser ||= OptionParser.new do |opts|
          opts.banner = "Usage: postmodern (archive|restore) <options>"

          opts.on('-f', '--filename FILE', 'File name of xlog') do |o|
            self.options[:file] = o
          end

          opts.on('-p', '--path PATH', 'Path of xlog file') do |o|
            self.options[:path] = o
          end

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("--version", "Show version") do
            require 'postmodern/version'
            puts Postmodern::VERSION
            exit
          end
        end
      end

      def run
        if local_script_exists?
          IO.popen("#{local_script} #{path} #{filename}",
                   env: {
            'WAL_ARCHIVE_PATH' => path,
            'WAL_ARCHIVE_FILE' => filename,
            'PATH' => ENV['PATH']
          }) { |f| puts f.gets }
        end
      end

      private

      def path
        @options[:path]
      end

      def filename
        @options[:file]
      end

      def local_script_exists?
        system({'PATH' => ENV['PATH']}, "which #{local_script} >/dev/null 2>/dev/null")
      end

      def local_script
        'postmodern_archive.local'
      end
    end
  end
end
