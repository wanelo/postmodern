require 'spec_helper'

describe 'pg_wal_restore' do
  before do
    double_cmd('pg_wal_restore.local')
  end

  context 'when local script exists' do
    before { double_cmd('which pg_wal_restore.local', exit: 0) }

    it 'succeeds' do
      expect {`bin/pg_wal_restore 1 2`}.to have_exit_status(0)
    end

    it 'calls a local file with file name and path' do
      expect {
        `bin/pg_wal_restore 11111 222222`
      }.to shellout('pg_wal_restore.local 11111 222222')
    end
  end

  context 'when local script does not exists' do
    before { double_cmd('which pg_wal_restore.local', exit: 1) }

    it 'succeeds' do
      expect {`bin/pg_wal_restore 1 2`}.to have_exit_status(0)
    end

    it 'does nothing' do
      expect {
        `bin/pg_wal_restore 11111 222222`
      }.not_to shellout('pg_wal_restore.local')
    end
  end
end
