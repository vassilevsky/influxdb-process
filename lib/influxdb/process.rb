require "influxdb"
require "influxdb/process/version"

module InfluxDB
  module Process
    class Instrumentation
      def initialize(influxdb, series = 'process_metrics', interval = 10)
        Thread.new do
          loop do
            influxdb.write_point(series, tags: {process: process}, values: GC.stat)
            sleep(interval)
          end
        end
      end

      def process
        @process ||= ENV['INFLUXDB_PROCESS_NAME'] || $PROGRAM_NAME
      end
    end
  end
end
