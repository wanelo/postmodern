Postmodern
==========

[![Build Status](https://travis-ci.org/wanelo/postmodern.svg?branch=master)](https://travis-ci.org/wanelo/postmodern)

Tools for managing PostgreSQL databases.

* WAL archiving and restoration

## Installation

```bash
[sudo] gem install postmodern
```

As a system utility, this assumes that you are installing the gem into
the system's ruby, however that is installed.

## Usage

### WAL archives

The wal archiving scripts packaged in this gem are intended to serve as
wrappers for YOUR archiving mechanism. Changing the settings for WAL
archiving in `postgresql.conf` or in `recovery.conf` require full restarts
of PostgreSQL—using Postmodern, you can configure PostgreSQL once and swap
in local scripts to do the actual work.

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


## Contributing

1. Fork it ( http://github.com/<my-github-username>/postmodern/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
