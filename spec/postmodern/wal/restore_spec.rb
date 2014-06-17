require 'spec_helper'
require 'postmodern/wal/restore'

describe Postmodern::WAL::Restore do
  let(:stdout) { double(to_s: '') }
  let(:stderr) { double(to_s: '') }
  let(:status) { double(exitstatus: 0) }

  let(:filename) { "some_file" }
  let(:path) { "/path/to/file" }
  let(:arguments) { %W(--filename #{filename} --path #{path}) }

  subject(:restorer) { Postmodern::WAL::Restore.new(arguments) }

  before do
    allow(Open3).to receive(:capture3).and_return([stdout, stderr, status])
    allow(restorer).to receive(:exit)
  end

  describe '#run' do
    let(:expected_command) { "postmodern_restore.local #{path} #{filename}" }

    context 'when local script exists' do
      before { double_cmd('which postmodern_restore.local', exit: 0) }

      it 'executes postmodern_restore.local with filename and path' do
        restorer.run
        expect(Open3).to have_received(:capture3).with(
          {
            'WAL_ARCHIVE_PATH' => path,
            'WAL_ARCHIVE_FILE' => filename,
            'PATH' => anything
          },
          expected_command
        )
      end
    end

    context 'when local script does not exist' do
      before { double_cmd('which postmodern_restore.local', exit: 1) }

      it 'executes postmodern_restore.local with filename and path' do
        restorer.run
        expect(Open3).not_to have_received(:capture3)
      end
    end
  end
end
