require 'postmodern/command'
require 'postmodern/db/adapter'

module Postmodern
  module Vacuum
    class Vacuum < Postmodern::Command
      default_option :timeout, 120
      default_option :pause, 10
      default_option :ratio, 0.05
      default_option :tablesize, 1000000
      default_option :freezeage, 10000000
      default_option :costdelay, 20
      default_option :costlimit, 2000
      default_option :user, 'postgres'
      default_option :port, 5432
      default_option :host, '127.0.0.1'

      required_option :database

      def parser
        @parser ||= OptionParser.new do |opts|
          opts.banner = "Usage: postmodern (vacuum|freeze) <options>"

          opts.on('-U', '--user USER', 'Defaults to postgres') do |opt|
            self.options[:user] = opt
          end

          opts.on('-p', '--port PORT', Integer, 'Defaults to 5432') do |opt|
            self.options[:port] = opt
          end

          opts.on('-H', '--host HOST', 'Defaults to 127.0.0.1') do |opt|
            self.options[:host] = opt
          end

          opts.on('-W', '--password PASS') do |opt|
            self.options[:password] = opt
          end

          opts.separator ''

          opts.on('-t', '--timeout TIMEOUT', Integer, 'Halt after timeout minutes -- default 120') do |opt|
            self.options[:timeout] = opt
          end

          opts.on('-P', '--pause PAUSE', Integer, 'Pause (minutes) after each table vacuum -- default 10') do |opt|
            self.options[:pause] = opt
          end

          opts.on('-d', '--database DB', 'Database to vacuum. Required.') do |opt|
            self.options[:database] = opt
          end

          opts.separator ''

          opts.on('-r', '--ratio RATIO', Float, 'minimum dead tuple ratio to vacuum -- default 0.05') do |opt|
            self.options[:ratio] = opt
          end

          opts.on('-B', '--tablesize BYTES', Integer, 'minimum table size to vacuum -- default 1000000') do |opt|
            self.options[:tablesize] = opt
          end

          opts.on('-F', '--freezeage AGE', Integer, 'minimum freeze age -- default 10000000') do |opt|
            self.options[:freezeage] = opt
          end

          opts.on('-D', '--costdelay DELAY', Integer, 'vacuum_cost_delay setting in ms -- default 20') do |opt|
            self.options[:costdelay] = opt
          end

          opts.on('-L', '--costlimit LIMIT', Integer, 'vacuum_cost_limit setting -- default 2000') do |opt|
            self.options[:costlimit] = opt
          end

          opts.separator ''

          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end

          opts.on_tail("-n", "--dry-run", "Perform dry-run, do not vacuum.") do
            self.options[:dryrun] = true
          end

          opts.on_tail("--version", "Show version") do
            require 'postmodern/version'
            puts Postmodern::VERSION
            exit
          end
        end
      end

      attr_reader :adapter, :start_time

      def initialize(args)
        @start_time = Time.now
        super(args)
      end

      def run
        configure_vacuum_cost
        vacuum
      end

      def configure_vacuum_cost
        adapter.execute("SET vacuum_cost_delay = '%d ms'" % options[:costdelay])
        adapter.execute("SET vacuum_cost_limit = '%d'" % options[:costlimit])
        adapter.execute("SET statement_timeout = 0")
      end

      def vacuum
        tables_to_vacuum_size = tables_to_vacuum.size
        tables_to_vacuum.each_with_index do |table,index|
          Postmodern.logger.info "Vacuuming #{table}"
          adapter.execute(vacuum_statement(table)) unless dryrun?
          if timedout?
            Postmodern.logger.warn "Vacuuming timed out"
            break
          end
          pause unless index == tables_to_vacuum_size - 1
        end
        Postmodern.logger.info "Vacuuming finished"
      end

      def vacuum_statement table_name
        "VACUUM ANALYZE %s" % table_name
      end

      def timedout?
        Time.now >= start_time + (options[:timeout].to_i * 60)
      end

      def pause
        pause_time = options[:pause].to_i * 60
        Postmodern.logger.info "Pausing before next vacuum for #{options[:pause]} minutes."
        sleep(pause_time) unless dryrun?
      end

      def dryrun?
        !!options[:dryrun]
      end

      def tables_to_vacuum
        table_res = adapter.execute(table_sql)
        table_res.map{|f| f['full_table_name']}
      end

      def adapter
        @adapter ||= Postmodern::DB::Adapter.new({
          dbname: options[:database],
          port: options[:port],
          host: options[:host],
          user: options[:user],
          password: options[:password]
        })
      end

      protected

      def table_sql
        <<-SQL.gsub(/^\s{8}/, '')
        WITH deadrow_tables AS (
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
        WHERE dead_pct > #{options[:ratio]}
        AND table_bytes > #{options[:tablesize]}
        ORDER BY dead_pct DESC, table_bytes DESC;
        SQL
      end
    end
  end
end
