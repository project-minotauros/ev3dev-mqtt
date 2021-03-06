module Ev3dev
  class TachoMotor < Device
    PATH = "/sys/class/tacho-motor/"

    lookup_files :address, :commands, :count_per_rot, :driver_name, :max_speed, :stop_actions, read_once: true
    lookup_files :duty_cycle, :position, :speed, :state, read: true
    lookup_files :command, :duty_cycle_sp, :polarity, :position_sp, :ramp_down_sp, :ramp_up_sp, :speed_sp, :stop_action, :time_sp, read: true, write: true

    setup_autoscan PATH

    def initialize(motor)
      super PATH + motor
    end
  end
end
