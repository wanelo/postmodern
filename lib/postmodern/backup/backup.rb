require 'postmodern/command'
require 'fileutils'
require 'open3'

module Postmodern
  module Backup
    class Backup < Postmodern::Command
      required_option :data_directory, :directory, :host, :name
      default_option :user, 'postgres'
      default_option :pigz, false
      default_option :concurrency, 4

      def parser
        @parser ||= OptionParser.new do |opts|
          opts.banner = 'Usage: postmodern backup <options>'

          opts.separator ''
          opts.separator 'Creates a gzipped archive of a pg_basebackup, with file name:'
          opts.separator '  NAME.basebackup.CURRENTDATE.tar.gz'
          opts.separator ''

          opts.on('-U', '--user USER', 'Postgres user (default: "postgres")') do |o|
            self.options[:user] = o
          end

          opts.on('-D', '--data-directory DIRECTORY', 'Name of data directory (eg: data93, data94) (required)') do |o|
            self.options[:data_directory] = o
          end

          opts.on('-d', '--directory DIRECTORY', 'Local directory to put backups (required)') do |o|
            self.options[:directory] = o
          end

          opts.on('-H', '--host HOST', 'Host of database master (eg: fqdn, IP) (required)') do |o|
            self.options[:host] = o
          end

          opts.on('-n', '--name NAME', 'Name of backup (required)') do |o|
            self.options[:name] = o
          end

          opts.on('--pigz CONCURRENCY', 'Use pigz with concurrency CONCURRENCY') do |o|
            self.options[:pigz] = true
            self.options[:concurrency] = o
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
        setup_environment
        run_basebackup
      end

      private

      # option wrappers

      def data_directory
        @options[:data_directory]
      end

      def directory
        @options[:directory]
      end

      def host
        @options[:host]
      end

      def name
        @options[:name]
      end

      def user
        @options[:user]
      end

      # backup methods

      def archive_command
        return 'gzip -9' unless options[:pigz]
        "pigz -9 -p #{options[:concurrency]}"
      end

      def archive_file
        "#{directory}/#{name}.basebackup.#{current_date}.tar.gz"
      end

      def basebackup_command
        "pg_basebackup --checkpoint=fast -F tar -D - -U #{user} -h #{host} | #{archive_command} > #{archive_file}"
      end

      def current_date
        Time.now.strftime('%Y%m%d')
      end

      def run_basebackup
        $stderr.puts "Creating basebackup: #{host}"
        stdout, stderr, status = Open3.capture3(script_env, basebackup_command)
        $stdout.print stdout
        $stderr.print stderr
        exit status.exitstatus
      end

      def setup_environment
        FileUtils.mkdir_p(directory)
      end

      def script_env
        {
          'PATH' => ENV['PATH']
        }
      end
    end
  end
end

