require 'spec_helper'

describe 'pg_wal_archive' do
  before do
    double_cmd('pg_wal_archive.local')
    double_cmd('which', exit: 1)
  end

  it 'exports second argument as WAL_ARCHIVE_FILE' do
    expect(`bin/pg_wal_archive filepath filename`).to include('Archiving file: filename')
  end

  it 'exports first argument WAL_ARCHIVE_PATH' do
    expect(`bin/pg_wal_archive filepath filename`).to include('path: filepath')
  end

  context 'when local script is present' do
    before { double_cmd('which pg_wal_archive.local', exit: 0) }

    it 'succeeds' do
      expect { `bin/pg_wal_archive 1 2` }.to have_exit_status(0)
    end

    it 'calls a local file with file name and path' do
      expect {
        `bin/pg_wal_archive 11111 222222`
      }.to shellout('pg_wal_archive.local 11111 222222')
    end
  end

  context 'when local script is not present' do
    before { double_cmd('which pg_wal_archive.local', exit: 1) }

    it 'succeeds' do
      expect { `bin/pg_wal_archive 1 2` }.to have_exit_status(0)
    end

    it 'does nothing' do
      expect {
        `bin/pg_wal_archive 11111 222222`
      }.not_to shellout('pg_wal_archive.local 11111 222222')
    end
  end
end
