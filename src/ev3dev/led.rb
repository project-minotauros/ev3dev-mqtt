module Ev3dev
  class Led < Device
    PATH = "/sys/class/leds/"

    lookup_files :max_brightness, :trigger, read_once: true
    lookup_files :brightness, read: true, write: true

    setup_autoscan PATH

    def initialize(led = nil, side: nil, color: nil)
      if led.nil?
        raise ArgumentError unless [0, 1].include? side
        raise ArgumentError unless %w(red green).include? color
        super PATH + "led#{side}\:#{color}\:brick-status/"
      else
        super PATH + led
      end
    end
  end
end
