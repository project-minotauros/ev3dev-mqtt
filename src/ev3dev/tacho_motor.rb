module Ev3dev
  class TachoMotor < Device
    PATH = "/sys/class/tacho-motor/motor"

    lookup_files :address, :commands, :count_per_rot, :driver_name, :duty_cycle, :max_speed, :position, :speed, :state, :stop_actions, read: true
    lookup_files :command, :duty_cycle_sp, :polarity, :position_sp, :ramp_down_sp, :ramp_up_sp, :speed_sp, :stop_action, :time_sp, read: true, write: true

    def initialize(number)
      super PATH + number.to_s
    end
  end
end
