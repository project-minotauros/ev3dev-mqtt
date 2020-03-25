module Ev3dev
  class Battery < Device
    PATH = "/sys/class/power_supply/"

    lookup_files :current_now, :scope, :technology, :type, :voltage_now, :voltage_min_design, :voltage_max_design, read: true

    def initialize (battery = "lego-ev3-battery")
      super PATH + battery
    end
  end
end
