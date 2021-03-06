Postmodern
==========

[![Build Status](https://travis-ci.org/wanelo/postmodern.svg?branch=master)](https://travis-ci.org/wanelo/postmodern)

Tools for managing PostgreSQL databases.

* Vacuum and Vacuum freeze tasks
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

### Backup

Backup all databases in a Postgres instance using `pg_basebackup`. This assumes that
there are no additional tablespaces (see the documentation on
`pg_basebackup`).

```
Usage: postmodern backup <options>

Creates a gzipped archive of a pg_basebackup, with file name:
  NAME.basebackup.CURRENTDATE.tar.gz

    -U, --user USER                  Postgres user (default: "postgres")
    -d, --directory DIRECTORY        Local directory to put backups (required)
    -H, --host HOST                  Host of database (eg: fqdn, IP) (required)
    -p, --port PORT                  Port of database (default: 5432)
    -n, --name NAME                  Name of backup (required)
        --pigz CONCURRENCY           Use pigz with concurrency CONCURRENCY
    -h, --help                       Show this message
        --version                    Show version
```

`CURRENTDATE` will be in the format `YYYYMMDD`, and will be the contents of the
Postgres data directory of the backed-up instance. When restoring from
these backups, note that it should be untarred directly into a new data
directory. For instance, if Postgres on the restored hosts is configured
with a data directory of `/var/pgsql/data94`, then the archive should be
untarred within `/var/pgsql/data94`, not in the parent directory.


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

`--pause` is useful to allow I/O-bound replicas to catch up on replication
before starting new vacuum events. When vacuuming large tables with many
dead tuples, a lot of changes need to be sent to replicas. When using replicas
with spinning disks, this can saturate the I/O of the disk array.

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

Contributions will not be accepted without tests. What should be a
feature and what a unit test is highly open to interpretation, however.
In some cases, a unit test may be easier and acceptable. In general,
at least one feature should be written for each new subcommand, even
if it just runs `--help`.

If in doubt, open an issue. If you don't receive a response to an issue
or a pull request, please mention one of the core committers of this
gem in a comment to make sure it doesn't get swallowed in an email abyss.
