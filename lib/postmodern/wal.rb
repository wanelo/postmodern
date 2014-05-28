require 'postmodern/wal/archive'
require 'postmodern/wal/restore'

module Postmodern
  module WAL
    COMMANDS = {
      'archive' => Postmodern::WAL::Archive,
      'restore' => Postmodern::WAL::Restore
    }

    def self.run(command, filename, path)
      COMMANDS[command].new(filename, path).run
    end
  end
end
