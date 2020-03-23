module Ev3dev
  class Device
    attr_reader :device_path

    def initialize(path)
      @device_path = path
    end

    def self.lookup_files *files
      files.each do |f|
        file = File.join device_path, f
        raise ArgumentError unless File.exist? file
        define_method f do
          read(file)
        end
        define_method "#{f}=" do |value|
          write(file, value: value)
        end
      end
    end

    def self.read_only *files
      files.each do |f|
        file = File.join device_path, f
        raise ArgumentError unless File.exist? file
        define_method f do
          read(file)
        end
      end
    end

    def self.write_only *files
      files.each do |f|
        file = File.join device_path, f
        raise ArgumentError unless File.exist? file
        define_method "#{f}=" do |value|
          write(f, value: value)
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
