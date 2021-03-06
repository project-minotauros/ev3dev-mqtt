module Ev3dev
  class Sensor < Device
    PATH = "/sys/class/lego-sensor/"

    lookup_files :address, :commands, :driver_name, :fw_version, :modes, read_once: true
    lookup_files :bin_data, :bin_data_format, :decimals, :direct, :num_values, :poll_ms, :text_value, :units, read: true
    lookup_files :command, :mode, read: true, write: true
    lookup_files :value0, :value1, :value2, :value3, :value4, :value5, :value6, :value7, read: true

    setup_autoscan PATH

    def initialize(sensor)
      super PATH + sensor
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
