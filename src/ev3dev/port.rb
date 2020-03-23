module Ev3dev
  class LegoPort < Device
    PATH = "/sys/class/lego-port/port"

    lookup_files :address, :driver_name, :modes, :status, read: true
    lookup_files :mode, :set_device, read: true, write: true

    def initialize(port)
      super PATH + port.to_s
    end
  end
end
