# InfluxDB::Process

Gathers metrics from the Ruby process it is executed in and sends them to an InfluxDB database.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'influxdb-process'
```

And then execute:

    $ bundle

Or do all this at once:

    $ bundle add influxdb-process

## Usage

This library assumes that you already have a working InfluxDB client instance.
It does not attempt to create one for you.
If not, see [InfluxDB Ruby](https://github.com/influxdata/influxdb-ruby) for client initialization instructions.
Let's say you have the client in the `influxdb` variable, as it says.

Add this to any place in your Ruby program:

```ruby
InfluxDB::Process::Instrumentation.new(influxdb).start
```

When you deploy this, the process where this code is executed will create a new thread.
It will periodically collect process metrics and send them to InfluxDB via the provided client.

Alternatively, you can instrument whenever you want (after each request / job / batch):

```ruby
# in an initializer, once
p = InfluxDB::Process::Instrumentation.new(influxdb)

# later, in an appropriate place, as many times as needed
p.instrument
```

You can pass additional options to customize the behavior of this gem. Here they are (with default values):

```ruby
InfluxDB::Process::Instrumentation.new(
  influxdb,
  memory_series: 'process_memory',
  object_series: 'process_objects',
  interval: 10, # seconds
  process: $PROGRAM_NAME
)
```

Metrics will be tagged with process name.
By default, `$0`/`$PROGRAM_NAME` will be used.
You can set your own process name via an additional keyword argument in the constructor. For example:

```ruby
InfluxDB::Process::Instrumentation.new(influxdb, process: 'report_generator')
```

You can also set the `INFLUXDB_PROCESS_NAME` environment variable:

    INFLUXDB_PROCESS_NAME=cache_cleaner bundle exec ruby ...

It will take precedence over the keyword argument.

## Limitations

System memory metrics (total, resident, shared memory used by the process as seen from the OS) are read
for the `/proc` filesystem. They are not reported on systems where it is not available.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

How to test this gem:
* Install and run InfluxDB
* Create a `test` database in it
* Run `make`

It will generate metrics and push them to the `test` database.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version:
* Update the version number in `version.rb`
* Run `bundle exec rake release`, which will do the following:
  * create a git tag for the version
  * push git commits and tags
  * push the `.gem` file to [rubygems.org](https://rubygems.org)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vassilevsky/influxdb-process

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
