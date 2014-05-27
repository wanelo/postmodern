require 'spec_helper'

describe 'pg_wal_restore' do
  before do
    double_cmd('pg_wal_restore.local')
  end

  it 'calls a local file with file name and path' do
    expect {
      `bin/pg_wal_restore 11111 222222`
    }.to shellout('pg_wal_restore.local 11111 222222')
  end
end
