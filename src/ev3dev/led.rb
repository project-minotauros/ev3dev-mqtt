module Ev3dev
  class Led < Device
    PATH = "/sys/class/leds/"

    lookup_files :max_brightness, :trigger, read: true
    lookup_files :brightness, read: true, write: true

    def initialize(side, color)
      raise ArgumentError unless [0, 1].include? side
      raise ArgumentError unless %w(red green).include? color
      super PATH + "led#{side}\:#{color}\:brick-status/"
    end
  end
end
