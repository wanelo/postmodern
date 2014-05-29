require 'spec_helper'
require 'postmodern/db/adapter'

describe Postmodern::DB::Adapter do
  subject(:adapter) { Postmodern::DB::Adapter.new(configuration) }

  let(:password) { 'secure...' }
  let(:configuration) do
    {
      stuff: 'things'
    }
  end

  describe '#adapter' do
    context 'with password' do
      let(:configuration) { {stuff: 'things', password: 'password'} }

      it 'initializes a PG adapter' do
        expect(PG).to receive(:connect).with({stuff: 'things', password: 'password'})
        adapter.pg_adapter
      end
    end

    context 'without password' do
      let(:configuration) { {stuff: 'things', password: nil} }

      it 'initializes a PG adapter without password params' do
        expect(PG).to receive(:connect).with({stuff: 'things'})
        adapter.pg_adapter
      end
    end
  end

  describe '#execute' do
    let(:pg_adapter) { double }

    before do
      allow(adapter).to receive(:pg_adapter).and_return(pg_adapter)
    end

    it 'delegates to PG adapter' do
      expect(pg_adapter).to receive(:exec).with('blah;')
      adapter.execute('blah;')
    end
  end
end
