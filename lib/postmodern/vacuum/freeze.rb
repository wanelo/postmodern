require 'postmodern/vacuum/vacuum'

module Postmodern
  module Vacuum
    class Freeze < Postmodern::Vacuum::Vacuum

      def vacuum_statement table_name
        "VACUUM FREEZE ANALYZE %s" % table_name
      end

      protected

      def table_sql
        <<-SQL.gsub(/^\s{8}/, '')
        WITH tabfreeze AS (
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
        WHERE freeze_age > #{options[:freezeage]}
        ORDER BY freeze_age DESC
        LIMIT 1000;
        SQL
      end
    end
  end
end
