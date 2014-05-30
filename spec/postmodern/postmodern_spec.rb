require 'spec_helper'
require 'postmodern'

describe Postmodern do
  describe '.logger' do
    it 'is a Logger' do
      expect(Postmodern.logger).to be_a Logger
    end
  end
end
