require "influxdb"
require "influxdb/process/version"

module InfluxDB
  module Process
    class Instrumentation
      def initialize(influxdb, memory_series: 'process_memory', object_series: 'process_objects', interval: 10, process: nil)
        @pid = Process.pid
        @process = ENV['INFLUXDB_PROCESS_NAME'] || process || $PROGRAM_NAME
        @page_size = `getconf PAGESIZE`.to_i rescue 4096

        Thread.new do
          loop do
            influxdb.write_point(memory_series, tags: {process: @process}, values: memory_values)
            influxdb.write_point(object_series, tags: {process: @process}, values: object_values)
            sleep(interval)
          end
        end
      end

      private

      def memory_values
        size, resident, share, text, _lib, data, _dt = File.read("/proc/#{@pid}/statm").split(' ').map do |pages|
          pages.to_i * @page_size
        end

        objects = ObjectSpace.count_objects_size

        memory = {
          total:    size,
          resident: resident,
          shared:   share,
          program:  text,
          data:     data,

          all_objects:      objects[:TOTAL],
          simple_objects:   objects[:T_OBJECT],
          classes:          objects[:T_CLASS],
          modules:          objects[:T_MODULE],
          floats:           objects[:T_FLOAT],
          strings:          objects[:T_STRING],
          regexes:          objects[:T_REGEXP],
          arrays:           objects[:T_ARRAY],
          hashes:           objects[:T_HASH],
          structs:          objects[:T_STRUCT],
          bignums:          objects[:T_BIGNUM],
          files:            objects[:T_FILE],
          data_objects:     objects[:T_DATA],
          matches:          objects[:T_MATCH],
          complex_numbers:  objects[:T_COMPLEX],
          rational_numbers: objects[:T_RATIONAL],
          symbols:          objects[:T_SYMBOL],
          ast_nodes:        objects[:T_NODE],
          included_modules: objects[:T_ICLASS],
        }

        if defined?(ActiveRecord::Base)
          memory[:ar_models] = ObjectSpace.memsize_of_all(ActiveRecord::Base)
        end

        memory
      end

      def object_values
        objects = ObjectSpace.count_objects
        gc = GC.stat

        {
          total_objects:     objects[:TOTAL],
          free_object_slots: objects[:FREE],
          simple_objects:    objects[:T_OBJECT],
          classes:           objects[:T_CLASS],
          modules:           objects[:T_MODULE],
          floats:            objects[:T_FLOAT],
          strings:           objects[:T_STRING],
          regexes:           objects[:T_REGEXP],
          arrays:            objects[:T_ARRAY],
          hashes:            objects[:T_HASH],
          structs:           objects[:T_STRUCT],
          bignums:           objects[:T_BIGNUM],
          files:             objects[:T_FILE],
          data_objects:      objects[:T_DATA],
          matches:           objects[:T_MATCH],
          complex_numbers:   objects[:T_COMPLEX],
          rational_numbers:  objects[:T_RATIONAL],
          symbols:           objects[:T_SYMBOL],
          ast_nodes:         objects[:T_NODE],
          included_modules:  objects[:T_ICLASS],

          heap_available_slots: gc[:heap_available_slots],
          heap_live_slots:      gc[:heap_live_slots],
          heap_free_slots:      gc[:heap_free_slots],
        }
      end
    end
  end
end
