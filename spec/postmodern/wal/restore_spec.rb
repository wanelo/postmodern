require 'spec_helper'
require 'postmodern/wal/restore'

describe Postmodern::WAL::Restore do
  before { allow(IO).to receive(:popen) }

  let(:filename) { "some_file" }
  let(:path) { "/path/to/file" }

  subject(:restorer) { Postmodern::WAL::Restore.new(filename, path) }

  describe '#run' do
    let(:expected_command) { "postmodern_restore.local #{path} #{filename}" }

    context 'when local script exists' do
      before { double_cmd('which postmodern_restore.local', exit: 0) }

      it 'executes postmodern_restore.local with filename and path' do
        restorer.run
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
      before { double_cmd('which postmodern_restore.local', exit: 1) }

      it 'executes postmodern_restore.local with filename and path' do
        restorer.run
        expect(IO).not_to have_received(:popen)
      end
    end
  end
end
