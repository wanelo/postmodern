require 'spec_helper'

describe 'vacuum help' do
  it 'responds' do
    expect(`bin/postmodern vacuum --help`).to eq <<-END
Usage: postmodern (vacuum|freeze) <options>
    -U, --user USER                  Defaults to postgres
    -p, --port PORT                  Defaults to 5432
    -H, --host HOST                  Defaults to 127.0.0.1
    -W, --password PASS

    -t, --timeout TIMEOUT            Halt after timeout minutes -- default 120
    -P, --pause PAUSE                Pause (minutes) after each table vacuum -- default 10
    -d, --database DB                Database to vacuum. Required.

    -r, --ratio RATIO                minimum dead tuple ratio to vacuum -- default 0.05
    -B, --tablesize BYTES            minimum table size to vacuum -- default 1000000
    -F, --freezeage AGE              minimum freeze age -- default 10000000
    -D, --costdelay DELAY            vacuum_cost_delay setting in ms -- default 20
    -L, --costlimit LIMIT            vacuum_cost_limit setting -- default 2000

    -h, --help                       Show this message
    -n, --dry-run                    Perform dry-run, do not vacuum.
        --version                    Show version
    END
  end
end
