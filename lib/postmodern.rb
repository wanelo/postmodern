require "postmodern/version"
require 'logger'

module Postmodern
  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end
end
