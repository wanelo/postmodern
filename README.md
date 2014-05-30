Postmodern
==========

[![Build Status](https://travis-ci.org/wanelo/postmodern.svg?branch=master)](https://travis-ci.org/wanelo/postmodern)

Tools for managing PostgreSQL databases.

* WAL archiving and restoration

## Dependencies

* libpq
* [pg gem](http://rubygems.org/gems/pg)

## Installation

```bash
[sudo] gem install postmodern
```

As a system utility, this assumes that you are installing the gem into
the system's ruby, however that is installed.

## Usage

### Vacuuming and Vacuum Freezing

Postmodern's vacuum scripts run table by table, with various constraints
to limit the overhead of the process.

```
Usage: postmodern (vacuum|freeze) <options>
    -U, --user USER                  Defaults to postgres
    -p, --port PORT                  Defaults to 5432
    -H, --host HOST                  Defaults to 127.0.0.1
    -W, --password PASS

    -t, --timeout TIMEOUT            Halt after timeout minutes -- default 120
    -d, --database DB                Database to vacuum. Required.

    -B, --tablesize BYTES            minimum table size to vacuum -- default 1000000
    -F, --freezeage AGE              minimum freeze age -- default 10000000
    -D, --costdelay DELAY            vacuum_cost_delay setting in ms -- default 20
    -L, --costlimit LIMIT            vacuum_cost_limit setting -- default 2000

    -h, --help                       Show this message
        --version                    Show version
```

To run a vacuum:

```
postmodern vacuum -U postgres -p 5432 -d my_database
```

In order to run vacuum freeze:

```
postmodern freeze -U postgres -p 5432 -d my_database
```

These tasks are designed to be run regularly during a window of lower
database activity. They vacuum or vacuum freeze each table that requires
it (based on command line options). Before each operation, the scripts check
to make sure they have not gone longer than `--timeout` seconds.

### WAL archives

The wal archiving scripts packaged in this gem are intended to serve as
wrappers for YOUR archiving mechanism. Changing the settings for WAL
archiving in `postgresql.conf` or in `recovery.conf` require full restarts
of PostgreSQL—using Postmodern, you can configure PostgreSQL once and swap
in local scripts to do the actual work.

```
Usage: postmodern (archive|restore) <options>
    -f, --filename FILE              File name of xlog
    -p, --path PATH                  Path of xlog file
    -h, --help                       Show this message
        --version                    Show version
```

In postgresql.conf

```
archive_command = 'postmodern archive --path %p --filename %f'
```

In recovery.conf

```
restore_command = 'postmodern restore --path %p --filename %f'
```

By default these scripts will do nothing. With the presence of local
scripts available in the path, the following variables will be
exported to the environment and the local scripts called (with arguments
preserved):

```ruby
ENV['WAL_ARCHIVE_PATH'] = path
ENV['WAL_ARCHIVE_FILE'] = filename
```

Local scripts can be written in any language. They should be able access
the relevant arguments either as $1, $2 or using the variables listed above.

`archive` will attempt to call a `postmodern_archive.local` script.
`restore` will attempt to call a `postmodern_restore.local` script.

see the [examples](https://github.com/wanelo/postmodern/tree/master/examples)
directory for example local scripts.

## Attribution & Thanks

Please see the [attribution](https://github.com/wanelo/postmodern/blob/master/ATTRIBUTION.md)
file for proper attribution and thanks.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/postmodern/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
