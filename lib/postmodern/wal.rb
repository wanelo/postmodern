require 'postmodern/wal/archive'
require 'postmodern/wal/restore'
require 'postmodern/errors'

module Postmodern
  module WAL
    COMMANDS = {
      'archive' => Postmodern::WAL::Archive,
      'restore' => Postmodern::WAL::Restore
    }

    def self.run(command, options)
      validate!(options)
      COMMANDS[command].new(options[:file], options[:path]).run
    end

    def self.validate!(options)
      unless options[:file] and options[:path]
        raise Postmodern::Error.new('Missing required options')
      end
    end
  end
end
