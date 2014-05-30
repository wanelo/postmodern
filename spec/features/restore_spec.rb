require 'spec_helper'

describe 'restore help' do
  it 'responds' do
    expect(`bin/postmodern restore --help`).to eq <<-END
Usage: postmodern (archive|restore) <options>
    -f, --filename FILE              File name of xlog
    -p, --path PATH                  Path of xlog file
    -h, --help                       Show this message
        --version                    Show version
    END
  end
end

describe 'restore' do
  let(:command) { `bin/postmodern restore --path filepath --filename filename` }

  let(:usage) { <<-END
Usage: postmodern (archive|restore) <options>
    -f, --filename FILE              File name of xlog
    -p, --path PATH                  Path of xlog file
    -h, --help                       Show this message
        --version                    Show version
                END
  }


  before do
    double_cmd('postmodern_restore.local')
  end

  describe 'validations' do
    context 'with no --path' do
      let(:command) { `bin/postmodern restore --filename filename` }

      it 'fails' do
        expect { command }.to have_exit_status(1)
      end

      it 'prints usage' do
        expect(command).to match(Regexp.escape(usage))
      end

      it 'includes missing params' do
        expect(command).to match('Missing path')
      end
    end

    context 'with no --filename' do
      let(:command) { `bin/postmodern restore --path path` }

      it 'fails' do
        expect { command }.to have_exit_status(1)
      end

      it 'prints usage' do
        expect(command).to match(Regexp.escape(usage))
      end

      it 'includes missing params' do
        expect(command).to match('Missing filename')
      end
    end
  end

  context 'when local script is present' do
    before { double_cmd('which', exit: 0) }

    it 'succeeds' do
      expect { command }.to have_exit_status(0)
    end

    it 'calls a local file with file name and path' do
      expect { command }.to shellout('postmodern_restore.local filepath filename')
    end
  end

  context 'when local script is not present' do
    before { double_cmd('which', exit: 1) }

    it 'succeeds' do
      expect { command }.to have_exit_status(0)
    end

    it 'does nothing' do
      expect { command }.not_to shellout('pg_wal_restore.local filepath filename')
    end
  end
end
