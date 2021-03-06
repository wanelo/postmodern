require 'optparse'

module Postmodern
  class Command
    class << self
      def inherited(subclass)
        subclass.instance_variable_set(:@required_options, @required_options)
        subclass.instance_variable_set(:@default_options, @default_options)
      end

      def required_options
        @required_options ||= []
      end

      def required_option(*options)
        required_options.concat(options)
        required_options.uniq!
      end

      def default_options
        @default_options ||= {}
      end

      def default_option(key, value)
        default_options[key] = value
      end
    end

    def parser
      raise "Command needs to define an OptionParser"
    end

    attr_reader :options

    def initialize(args)
      @options = self.class.default_options.dup

      parse_args(args)
      validate!
    end

    def run
    end

    def validate!
      if missing_params.any?
        puts "Missing #{missing_params.join(', ')}"
        usage!
      end
    end

    def missing_params
      self.class.required_options - self.options.keys
    end

    def parse_args(args)
      parser.parse!(args)
    end

    def usage!
      puts parser.to_s
      exit 1
    end
  end
end
