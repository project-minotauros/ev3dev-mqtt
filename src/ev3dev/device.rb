module Ev3dev
  class Device
    attr_reader :device_path

    def initialize(path)
      @device_path = path
    end

    def self.lookup_files *files, read: false, write: false
      files.each do |f|
        if read
          define_method f do
            file = File.join device_path, f.to_s
            raise ArgumentError unless File.exist? file
            read(file)
          end
        end
        if write
          define_method "#{f}=" do |value|
            file = File.join device_path, f.to_s
            raise ArgumentError unless File.exist? file
            write(file, value: value)
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
