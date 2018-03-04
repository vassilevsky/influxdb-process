require "objspace"

require "influxdb"
require "influxdb/process/version"

module InfluxDB
  module Process
    class Instrumentation
      def initialize(influxdb, memory_series: 'process_memory', object_series: 'process_objects', interval: 10, process: nil)
        @process = ENV['INFLUXDB_PROCESS_NAME'] || process || $PROGRAM_NAME
        @tags = {process: @process}

        @pid = ::Process.pid
        @system_memory_file = "/proc/#{@pid}/statm"
        @can_read_system_memory = File.exist?(@system_memory_file)
        @page_size = `getconf PAGESIZE`.to_i rescue 4096

        @memory = {}
        @objects = {}

        Thread.new do
          loop do
            update_memory
            update_objects

            influxdb.write_point(memory_series, tags: @tags, values: @memory)
            influxdb.write_point(object_series, tags: @tags, values: @objects)

            sleep(interval)
          end
        end
      end

      private

      TYPES = {
        :T_OBJECT   => :simple_objects,
        :T_CLASS    => :classes,
        :T_MODULE   => :modules,
        :T_FLOAT    => :floats,
        :T_STRING   => :strings,
        :T_REGEXP   => :regexes,
        :T_ARRAY    => :arrays,
        :T_HASH     => :hashes,
        :T_STRUCT   => :structs,
        :T_BIGNUM   => :bignums,
        :T_FILE     => :file_descriptors,
        :T_DATA     => :data_objects,
        :T_MATCH    => :matches,
        :T_COMPLEX  => :complex_numbers,
        :T_RATIONAL => :rational_numbers,
        :T_SYMBOL   => :symbols,
        :T_IMEMO    => :memos,
        :T_ICLASS   => :included_modules,
        :T_ZOMBIE   => :zombies,
        :TOTAL      => :objects_total,
        :FREE       => :free_object_slots,
      }.freeze

      def update_memory
        ObjectSpace.count_objects_size.each do |type, size|
          @memory[TYPES.fetch(type)] = size
        end

        if defined?(ActiveRecord::Base)
          @memory[:ar_models] = ObjectSpace.memsize_of_all(ActiveRecord::Base)
        end

        if @can_read_system_memory
          size, resident, share, text, _lib, data, _dt = File.read(@system_memory_file).split(' ').map do |pages|
            pages.to_i * @page_size
          end

          @memory[:total]    = size
          @memory[:resident] = resident
          @memory[:shared]   = share
          @memory[:program]  = text
          @memory[:data]     = data
        end
      end

      def update_objects
        ObjectSpace.count_objects.each do |type, count|
          @objects[TYPES.fetch(type)] = count
        end

        gc = GC.stat

        @objects[:heap_available_slots] = gc[:heap_available_slots]
        @objects[:heap_live_slots]      = gc[:heap_live_slots]
        @objects[:heap_free_slots]      = gc[:heap_free_slots]
      end
    end
  end
end
