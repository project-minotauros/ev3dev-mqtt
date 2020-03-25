module Ev3dev
  class Sensor < Device
    PATH = "/sys/class/lego-sensor/sensor"

    lookup_files :address, :bin_data, :bin_data_format, :commands, :decimals, :direct, :driver_name, :fw_version, :modes, :num_values, :poll_ms, :text_value, :units, read: true
    lookup_files :command, :mode, read: true, write: true
    lookup_files :value0, :value1, :value2, :value3, :value4, :value5, :value6, :value7, read: true

    def initialize(number)
      super PATH + number
    end

    def values
      vals = []
      num_values.to_i.times do |n|
        vals << send("value#{n}")
      end
      vals
    end
  end
end
