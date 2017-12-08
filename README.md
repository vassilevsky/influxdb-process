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
InfluxDB::Process::Instrumentation.new(influxdb)
```

When you deploy this, the process where this code is executed will create a new thread.
It will periodically collect process metrics and send them to InfluxDB via the provided client.

By default, metrics will be written to the `process_metrics` series every *10* seconds.
You can set your own series name and interval via additional keyword arguments:

```ruby
InfluxDB::Process::Instrumentation.new(influxdb, series: 'ruby_stats', interval: 42)
```

Metrics will be tagged with process name.
By default, `$0`/`$PROGRAM_NAME` will be used.
You can set your own process name via an additional keyword argument:

```ruby
InfluxDB::Process::Instrumentation.new(influxdb, process: 'report_generator')
```

You can also set the `INFLUXDB_PROCESS_NAME` environment variable:

    INFLUXDB_PROCESS_NAME=cache_cleaner bundle exec ruby ...

It will take precedence over the keyword argument.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

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
