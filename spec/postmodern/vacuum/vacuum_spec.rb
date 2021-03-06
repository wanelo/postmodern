require 'spec_helper'
require 'postmodern/vacuum/vacuum'
require 'timecop'

describe Postmodern::Vacuum::Vacuum do
  let(:args) { %w(-d mydb) }
  let(:adapter) { double }
  subject(:command) { Postmodern::Vacuum::Vacuum.new(args) }

  before do
    allow(Postmodern).to receive(:logger).and_return(FakeLogger.new)
    allow(adapter).to receive(:execute)
  end

  describe "#options" do
    {
      user: 'postgres',
      port: 5432,
      host: '127.0.0.1',
      timeout: 120,
      pause: 10,
      ratio: 0.05,
      tablesize: 1000000,
      freezeage: 10000000,
      costdelay: 20,
      costlimit: 2000
    }.each do |option, default|
      it "defaults on #{option}" do
        expect(command.options[option]).to eq(default)
      end
    end
  end

  describe 'validations' do
    let(:usage) { double(usage!: '') }

    before do
      allow_any_instance_of(Postmodern::Vacuum::Vacuum).
        to receive(:usage!) { usage.usage! }
    end

    describe 'database' do
      it 'requires database' do
        Postmodern::Vacuum::Vacuum.new([])
        expect(usage).to have_received(:usage!)
      end
    end
  end

  describe "#run" do
    let(:args) { %w(--database mydb) }

    before do
      allow(command).to receive(:configure_vacuum_cost)
      allow(command).to receive(:vacuum)
    end

    it 'executes vacuum operations in order' do
      command.run
      expect(command).to have_received(:configure_vacuum_cost).once
      expect(command).to have_received(:vacuum).once
    end
  end

  describe '#adapter' do
    before { allow(adapter).to receive(:execute) }

    it 'instantiates a DB::Adapter' do
      expect(Postmodern::DB::Adapter).to receive(:new).once.with({
        dbname: 'mydb',
        port: 5432,
        host: '127.0.0.1',
        user: 'postgres',
        password: nil
      }).and_return(adapter)
      command.adapter
    end

    context 'when password is present' do
      let(:args) { %w(--password mypass --database mydb) }
      it 'passes through to adapter' do
        expect(Postmodern::DB::Adapter).to receive(:new).once.with({
          dbname: 'mydb',
          port: 5432,
          host: '127.0.0.1',
          user: 'postgres',
          password: 'mypass'
        }).and_return(adapter)
        command.adapter
      end
    end
  end

  describe '#configure_vacuum_cost' do
    before do
      allow(command).to receive(:adapter).and_return(adapter)
      command.configure_vacuum_cost
    end

    it 'sets vacuum cost delay' do
      expect(adapter).to have_received(:execute).with("SET vacuum_cost_delay = '#{command.options[:costdelay]} ms'")
    end

    it 'sets vacuum cost limit' do
      expect(adapter).to have_received(:execute).with("SET vacuum_cost_limit = '#{command.options[:costlimit]}'")
    end
  end

  describe '#tables_to_vacuum' do
    let(:args) { %w(-d mydb -B 12345 -r 0.12345) }

    it 'finds list of tables to vacuum' do
      result = [
        {'full_table_name' => 'table1'},
        {'full_table_name' => 'table2'},
      ]
      allow(command).to receive(:adapter).and_return(adapter)
      expect(adapter).to receive(:execute).with(%Q{WITH deadrow_tables AS (
    SELECT relid::regclass as full_table_name,
        ((n_dead_tup::numeric) / ( n_live_tup + 1 )) as dead_pct,
        pg_relation_size(relid) as table_bytes
    FROM pg_stat_user_tables
    WHERE n_dead_tup > 100
    AND ( (now() - last_autovacuum) > INTERVAL '1 hour'
        OR last_autovacuum IS NULL )
)
SELECT full_table_name
FROM deadrow_tables
WHERE dead_pct > 0.12345
AND table_bytes > 12345
ORDER BY dead_pct DESC, table_bytes DESC;
}).and_return(result)

      expect(command.tables_to_vacuum).to eq(%w(table1 table2))
    end
  end

  describe "#vacuum" do
    before do
      allow(Postmodern::DB::Adapter).to receive(:new).and_return(adapter)
      allow(command).to receive(:tables_to_vacuum).and_return(tables_to_vacuum)
      allow(command).to receive(:pause)
    end

    let(:tables_to_vacuum) { %w(table1 table2 table3) }

    context 'dry run' do
      let(:args) { %w(-d db --dry-run) }
      it 'does not actually execute vacuum' do
        command.vacuum
        expect(adapter).not_to have_received(:execute)
      end
    end

    it "vacuums each table" do
      command.vacuum
      tables_to_vacuum.each do |table|
        expect(adapter).to have_received(:execute).with("VACUUM ANALYZE %s" % table)
      end
    end

    it "exits prematurely with a timeout and analyzes first table" do
      allow(command).to receive(:timedout?).and_return(true)
      command.vacuum
      expect(adapter).to have_received(:execute).with("VACUUM ANALYZE %s" % tables_to_vacuum[0])
      expect(adapter).not_to have_received(:execute).with("VACUUM ANALYZE %s" % tables_to_vacuum[1])
      expect(adapter).not_to have_received(:execute).with("VACUUM ANALYZE %s" % tables_to_vacuum[2])
    end

    it 'pauses between each vacuum' do
      command.vacuum
      expect(command).to have_received(:pause).exactly(2).times
    end
  end

  describe '#dryrun?' do
    context 'with --dry-run' do
      let(:args) { %w(-d db --dry-run) }

      it 'is true' do
        expect(subject.dryrun?).to be true
      end
    end

    context 'without --dry-run' do
      let(:args) { %w(-d db) }

      it 'is false' do
        expect(command.dryrun?).to be false
      end
    end
  end

  describe '#pause' do
    let(:time) { Time.now }
    let(:args) { %w(--d db -P 30) }

    before do
      allow(command).to receive(:sleep)
    end

    it "Should sleep for specified time" do
      command.pause
      expect(command).to have_received(:sleep).with(30 * 60).once
    end

    context 'during dry-run' do
      let(:args) { %w(--d db -P 30 --dry-run) }

      it "Should not sleep during dry-run" do
        command.pause
        expect(command).not_to have_received(:sleep)
      end
    end
  end

  describe '#timedout?' do
    let(:time) { Time.now }
    let(:args) { %w(--d db -t 15) }

    before do
      Timecop.freeze time do
        command # ensure command is initialized Now
      end
    end

    context 'current time is greater than timeout threshold since initialization' do
      it 'is true' do
        Timecop.freeze time + (15 * 60) do
          expect(command.timedout?).to be true
        end
      end
    end

    context 'current time is less than timeout threshold since initialization' do
      it 'is false' do
        Timecop.freeze time + (15 * 60 - 1) do
          expect(command.timedout?).to be false
        end
      end
    end
  end
end
