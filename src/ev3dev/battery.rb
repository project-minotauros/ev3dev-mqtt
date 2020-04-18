module Ev3dev
  class Battery < Device
    PATH = "/sys/class/power_supply/"

    lookup_files :scope, :technology, :type, :voltage_min_design, :voltage_max_design, read_once: true
    lookup_files :current_now, :voltage_now, read: true

    setup_autoscan PATH

    def initialize (battery = "lego-ev3-battery")
      super PATH + battery
    end
  end
end
