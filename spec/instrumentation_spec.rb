require 'influxdb/process'

RSpec.describe 'Process Instrumentation' do
  let(:influxdb){ double(write_point: nil) }

  it 'collects metrics and writes them to InfluxDB without exceptions' do
    expect(influxdb).to receive(:write_point).at_least(4).times
    InfluxDB::Process::Instrumentation.new(influxdb, interval: 1)
    sleep 2
  end
end
