module Ev3dev
  class Device
    attr_reader :device_path

    def initialize(path)
      @read_once_files = []
      @device_path = path
    end

    def read_once_attributes
      @read_once_files.map do |file|
        { file.to_sym => send(file.to_sym) }
      end.inject ({}) do |result, object|
        result.merge(object)
      end
    end

    def self.lookup_files *files, read: false, write: false, read_once: false
      files.each do |file|
        if read
          define_method file do
            read(file)
          end
        elsif read_once
          @read_once_files << file.to_sym
          define_method file do
            instance_variable_get("@#{file}") || instance_variable_set("@#{file}", read(file))
          end
        end
        if write
          define_method "#{file}=" do |value|
            write(file, value: value)
          end
        end
      end
    end

    class << self
      def setup_autoscan path
        singleton_class.send(:define_method, "autoscan") do
          Dir.entries(path).drop(2).map do |entry|
            self.new entry
          end
        end
      end
    end

    def write(file, value:)
      file = File.join @device_path, file.to_s
      raise "No such file #{file}" unless File.exist? file
      IO.write file, value
    end

    def read(file)
      file = File.join @device_path, file.to_s
      raise "No such file #{file}" unless File.exist? file
      IO.read(file).strip
    end
  end
end
