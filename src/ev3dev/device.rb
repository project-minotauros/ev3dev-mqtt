module Ev3dev
  class Device
    attr_reader :device_path

    def initialize(path)
      @device_path = path
    end

    def write(file, value:)
      file = File.join @device_path, file.to_s
      IO.write file, value
    end

    def read(file)
      file = File.join @device_path, file.to_s
      IO.read(file).strip
    end
  end
end
