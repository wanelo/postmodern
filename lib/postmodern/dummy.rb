require 'postmodern/command'

module Postmodern
  class Dummy < Command
    def run
      puts parser
      exit 1
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: postmodern <command> <options>"

        opts.separator ""
        opts.separator "Available commands:"
        opts.separator "    backup"
        opts.separator "    archive"
        opts.separator "    restore"
        opts.separator "    vacuum"
        opts.separator "    freeze"
        opts.separator ""
        opts.separator "Options:"

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
  end
end
