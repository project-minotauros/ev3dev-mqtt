require_relative 'common'

class MessageHandler
  def initialize connection
    @connection = connection

    @ports = Ev3dev::Port.autoscan
    @leds = Ev3dev::Led.autoscan
    @battery = Ev3dev::Battery.autoscan[0]
    @sensors = Ev3dev::Sensor.autoscan
    @tmotors = Ev3dev::TachoMotor.autoscan

    @connection.send(response_available_devices(AvailableDeivices::NONE))
  end

  def decode message
    header = message[0].codepoints
    payload = Marshal.load(message[1..])
    command = header & (7 << 11)
    subcommand = header & (7 << 8)
    device_type = header & (15 << 4)
    device_id = header & (15)
  end

  def encode response, device_type, device_id, payload
    message = response << 7
    message |= device_type << 3
    message |= device_id
    message = message.chr("UTF-8")
    message + Marshal.dump(payload)
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
