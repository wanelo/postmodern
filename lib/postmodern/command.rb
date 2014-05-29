require 'optparse'

module Postmodern
  class Command
    def self.required_options
      @required_options ||= []
    end

    def parser
      OptionParser.new
    end

    attr_reader :options

    def initialize(args)
      @options = {}

      parse_args(args)
      validate!
    end

    def run
    end

    def validate!
      if (self.class.required_options - self.options.keys).any?
        puts parser
        exit 1
      end
    end

    def parse_args(args)
      parser.parse!(args)
      self.options
    end
  end
end
