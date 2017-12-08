require "influxdb"
require "influxdb/process/version"

module InfluxDB
  module Process
    class Instrumentation
      def initialize(influxdb, series: 'process_metrics', interval: 10, process: nil)
        @process = ENV['INFLUXDB_PROCESS_NAME'] || process || $PROGRAM_NAME

        Thread.new do
          loop do
            influxdb.write_point(series, tags: {process: @process}, values: GC.stat)
            sleep(interval)
          end
        end
      end
    end
  end
end
