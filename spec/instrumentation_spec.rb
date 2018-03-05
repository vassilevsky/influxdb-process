require 'influxdb/process'

RSpec.describe 'Process Instrumentation' do
  let(:influxdb){ double(write_point: nil) }

  it 'collects metrics and writes them to InfluxDB without exceptions' do
    expect(influxdb).to receive(:write_point).at_least(2).times
    InfluxDB::Process::Instrumentation.new(influxdb).instrument
  end
end
