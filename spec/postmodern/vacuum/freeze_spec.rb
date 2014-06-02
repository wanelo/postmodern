require 'spec_helper'
require 'postmodern/vacuum/freeze'

describe Postmodern::Vacuum::Freeze do
  let(:adapter) { double }
  let(:args) { %w(-d db) }
  subject(:command) { Postmodern::Vacuum::Freeze.new(args) }

  before do
    allow(Postmodern).to receive(:logger).and_return(FakeLogger.new)
    allow(adapter).to receive(:execute)
    allow(command).to receive(:adapter).and_return(adapter)
  end

  describe '#tables_to_vacuum' do
    let(:args) { %w(-d mydb -F 12345) }

    it 'finds list of tables to vacuum' do
      result = [
        {'full_table_name' => 'table1'},
        {'full_table_name' => 'table2'},
      ]
      allow(command).to receive(:adapter).and_return(adapter)
      expect(adapter).to receive(:execute).with(%Q{WITH tabfreeze AS (
    SELECT pg_class.oid::regclass AS full_table_name,
    age(relfrozenxid)as freeze_age,
    pg_relation_size(pg_class.oid)
FROM pg_class JOIN pg_namespace ON relnamespace = pg_namespace.oid
WHERE nspname not in ('pg_catalog', 'information_schema')
    AND nspname NOT LIKE 'pg_temp%'
    AND relkind = 'r'
)
SELECT full_table_name
FROM tabfreeze
WHERE freeze_age > 12345
ORDER BY freeze_age DESC
LIMIT 1000;
}).and_return(result)

      expect(command.tables_to_vacuum).to eq(%w(table1 table2))
    end
  end

  describe '#vacuum' do
    let(:tables_to_vacuum) { %w(table1 table2 table3) }

    before do
      allow(Postmodern::DB::Adapter).to receive(:new).and_return(adapter)
      allow(command).to receive(:tables_to_vacuum).and_return(tables_to_vacuum)
      allow(command).to receive(:pause)
    end

    it "vacuums each table" do
      command.vacuum
      tables_to_vacuum.each do |table|
        expect(adapter).to have_received(:execute).with("VACUUM FREEZE ANALYZE %s" % table)
      end
    end
  end
end
