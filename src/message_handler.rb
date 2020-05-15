require_relative 'common'
require_relative 'ev3dev'

class MessageHandler
  def initialize connection
    @connection = connection

    @ports = Ev3dev::Port.autoscan
    @leds = Ev3dev::Led.autoscan
    @battery = Ev3dev::Battery.autoscan[0]
    @sensors = Ev3dev::Sensor.autoscan
    @tmotors = Ev3dev::TachoMotor.autoscan

    @connection.send(response_available_devices(AvailableDevices::NONE))
  end

  def decode message
    header = message[0].codepoints
    payload = message[1..message.length]
    command = (header >> 10) & 15
    subcommand = (header >> 7) & 7
    device_type = (header >> 3) & 15
    device_id = (header >> 0) & 7
    case command
    when InboundFlags::EXECUTE_COMMAND
      Thread.new (payload) do |command|
        @connection.send(encode(OutboundFlags::CONSOLE_OUTPUT, 0, 0, `#{command}`))
      end
    when InboundFlags::SCAN_DEVICES
      Thread.new (device_type) do |device|
        @connection.send(response_available_devices(device))
      end
    end
  end

  def encode response, device_type, device_id, payload
    message = response << 7
    message |= device_type << 3
    message |= device_id
    message = message.chr("UTF-8")
    message + Marshal.dump(payload).force_encoding(Encoding::UTF_8)
  end

private
  def response_available_devices devices
    # TODO: implement available devices selection
    encode(OutboundFlags::AVAILABLE_DEVICES, devices, 0, {
      battery: @battery.read_once_attributes,
      leds: @leds.map { |led| led.read_once_attributes },
      ports: @ports.map { |port| port.read_once_attributes },
      sensors: @sensors.map { |sensor| sensor.read_once_attributes },
      tmotors: @tmotors.map { |tmotor| tmotor.read_once_attributes }
    })
  end
end
