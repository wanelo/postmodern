require 'spec_helper'

describe 'restore' do
  let(:command) { `bin/postmodern restore --path filepath --filename filename` }

  before do
    double_cmd('postmodern_restore.local')
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
