require 'postmodern'
require 'postmodern/wal/archive'
require 'postmodern/wal/restore'
require 'postmodern/vacuum/vacuum'
require 'postmodern/vacuum/freeze'
require 'postmodern/dummy'

module Postmodern
  module Runner
    attr_reader :argv

    DEFAULT_COMMAND = Dummy
    COMMAND_MAP = {
      'archive' => WAL::Archive,
      'restore' => WAL::Restore,
      'vacuum' => Vacuum::Vacuum,
      'freeze' => Vacuum::Freeze
    }.freeze

    def self.run(args)
      command_for(args.first).new(args).run
    end
    
    def self.command_for(command)
      COMMAND_MAP[command] || DEFAULT_COMMAND
    end
  end
end
