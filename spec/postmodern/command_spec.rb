require 'spec_helper'
require 'postmodern/command'

describe Postmodern::Command do
  let(:option_parser) { double(parse!: true, to_s: nil) }
  subject(:command_class) { Class.new(Postmodern::Command) }

  before do
    local_scope_option_parser = option_parser
    command_class.send(:define_method, :parser) { local_scope_option_parser }
  end


  describe '#usage!' do
    it 'exits 1' do
      expect { command_class.new([]).usage! }.to raise_error(SystemExit)
    end

    it 'prints parser' do
      expect { command_class.new([]).usage! }.to raise_error(SystemExit)
      expect(option_parser).to have_received(:to_s)
    end
  end
end
