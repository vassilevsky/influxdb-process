require 'influxdb/process'

influxdb = InfluxDB::Client.new('test')
InfluxDB::Process::Instrumentation.new(influxdb, process: ENV['CUSTOM_PROCESS'])

OBJECTS = []

def create_many_objects
  1000.times do
    OBJECTS << ' ' * 1000
  end
end

10.times do
  create_many_objects
  sleep 10
end
