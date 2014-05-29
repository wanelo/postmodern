require 'spec_helper'
require 'postmodern/version'

describe 'dummy help' do
  it 'responds with usage info' do
    expect(`bin/postmodern --help`).to eq <<-END
Usage: postmodern <command> <options>

Available commands:
    archive
    restore

Options:
    -h, --help                       Show this message
        --version                    Show version
    END
  end
end

describe 'dummy version' do
  it 'responds with the Postmodern version' do
    expect(`bin/postmodern --version`).to match(Postmodern::VERSION)
  end
end
