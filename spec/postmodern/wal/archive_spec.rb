require 'spec_helper'
require 'postmodern/wal/archive'

describe Postmodern::WAL::Archive do
  before { allow(IO).to receive(:popen) }

  let(:filename) { "some_file" }
  let(:path) { "/path/to/file" }
  let(:arguments) { %W(--filename #{filename} --path #{path}) }

  subject(:archiver) { Postmodern::WAL::Archive.new(arguments) }

  describe '#run' do
    let(:expected_command) { "postmodern_archive.local #{path} #{filename}" }

    context 'when local script exists' do
      before { double_cmd('which postmodern_archive.local', exit: 0) }

      it 'executes postmodern_archive.local with filename and path' do
        archiver.run
        expect(IO).to have_received(:popen).with(expected_command, env:
          {
            'WAL_ARCHIVE_PATH' => path,
            'WAL_ARCHIVE_FILE' => filename,
            'PATH' => anything
          }
        )
      end
    end

    context 'when local script does not exist' do
      before { double_cmd('which postmodern_archive.local', exit: 1) }

      it 'executes postmodern_archive.local with filename and path' do
        archiver.run
        expect(IO).not_to have_received(:popen)
      end
    end
  end
end
