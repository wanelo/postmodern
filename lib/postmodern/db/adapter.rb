require 'pg'

module Postmodern
  module DB
    class Adapter

      attr_reader :config

      def initialize(config)
        @config = config
      end

      def pg_adapter
        @pg_adapter ||= PG.connect(db_configuration)
      end

      def execute(sql)
        pg_adapter.exec(sql)
      end

      private

      def db_configuration
        db_configuration = {}.merge(config)
        db_configuration.delete(:password) unless config[:password]
        db_configuration
      end
    end
  end
end
