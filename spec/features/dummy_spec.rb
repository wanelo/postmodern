require 'spec_helper'
require 'postmodern/version'

describe 'dummy' do
  let(:usage) {
    <<-END
Usage: postmodern <command> <options>

Available commands:
    archive
    restore
    vacuum
    freeze

Options:
    -h, --help                       Show this message
        --version                    Show version
    END
  }

  describe 'help' do
    it 'responds with usage info' do
      expect(`bin/postmodern --help`).to eq(usage)
    end
  end

  describe 'version' do
    it 'responds with the Postmodern version' do
      expect(`bin/postmodern --version`).to match(Postmodern::VERSION)
    end
  end

  describe 'argument catchall' do
    let(:command) { `bin/postmodern dlaskfjdflf` }

    it 'exits 1' do
      expect { command }.to have_exit_status(1)
    end

    it 'prints usage' do
      expect(command).to eq(usage)
    end
  end
end
