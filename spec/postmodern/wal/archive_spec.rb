require 'spec_helper'
require 'postmodern/wal/archive'

describe Postmodern::WAL::Archive do
  let(:stdout) { double(to_s: '') }
  let(:stderr) { double(to_s: '') }
  let(:status) { double(exitstatus: 0) }

  let(:filename) { "some_file" }
  let(:path) { "/path/to/file" }
  let(:arguments) { %W(--filename #{filename} --path #{path}) }

  subject(:archiver) { Postmodern::WAL::Archive.new(arguments) }

  before do
    allow(Open3).to receive(:capture3).and_return([stdout, stderr, status])
    allow(archiver).to receive(:exit)
  end

  describe '#run' do
    let(:expected_command) { "postmodern_archive.local #{path} #{filename}" }

    context 'when local script exists' do
      before { double_cmd('which postmodern_archive.local', exit: 0) }

      it 'executes postmodern_archive.local with filename and path' do
        archiver.run
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
      before { double_cmd('which postmodern_archive.local', exit: 1) }

      it 'executes postmodern_archive.local with filename and path' do
        archiver.run
        expect(Open3).not_to have_received(:capture3)
      end
    end
  end
end
