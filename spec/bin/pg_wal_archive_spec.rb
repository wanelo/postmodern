require 'spec_helper'

describe 'pg_wal_archive' do
  before do
    double_cmd('pg_wal_archive.local')
  end

  it 'exports WAL_ARCHIVE_FILE' do
    expect(`bin/pg_wal_archive filename filepath`).to include('Archiving file: filename')
  end

  it 'exports WAL_ARCHIVE_PATH' do
    expect(`bin/pg_wal_archive filename filepath`).to include('Archiving path: filepath')
  end

  it 'calls a local file with file name and path' do
    expect {
      `bin/pg_wal_archive 11111 222222`
    }.to shellout('pg_wal_archive.local')
  end
end
