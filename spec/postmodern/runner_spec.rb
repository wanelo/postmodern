require 'spec_helper'
require 'postmodern/runner'

describe Postmodern::Runner do

  describe '.command' do
    it 'chooses archiver' do
      expect(Postmodern::Runner.command_for('archive')).to be Postmodern::WAL::Archive
    end

    it 'chooses restorer' do
      expect(Postmodern::Runner.command_for('restore')).to be Postmodern::WAL::Restore
    end


    it 'chooses vacuumer' do
      expect(Postmodern::Runner.command_for('vacuum')).to be Postmodern::Vacuum::Vacuum
    end

    it 'defaults to dummy' do
      expect(Postmodern::Runner.command_for('ljfaldf')).to be Postmodern::Dummy
    end
  end

  describe '.run' do
    it 'runs the command class' do
      args = ['blahrgh', 'first', 'second']
      dummy_class = double
      expect(Postmodern::Runner).to receive(:command_for).and_return(dummy_class)
      expect(dummy_class).to receive(:new).with(args).and_return(dummy_class)
      expect(dummy_class).to receive(:run)
      Postmodern::Runner.run(args)
    end
  end
end
