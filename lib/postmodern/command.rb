require 'optparse'

module Postmodern
  class Command
    def self.required_options
      @required_options ||= []
    end

    def self.required_option(*options)
      required_options.concat(options)
    end

    def self.default_options
      @default_options ||= {}
    end

    def self.default_option(key, value)
      default_options[key] = value
    end

   def parser
     raise "Command needs to define an OptionParser"
   end

    attr_reader :options

    def initialize(args)
      @options = self.class.default_options

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
    end
  end
end
