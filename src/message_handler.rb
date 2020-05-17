require_relative 'common'
require_relative 'ev3dev'
require_relative 'info_updater'

class MessageHandler
  def initialize connection
    @connection = connection

    @info_updater = InfoUpdater.new

    @ports = Ev3dev::Port.autoscan
    @leds = Ev3dev::Led.autoscan
    @battery = Ev3dev::Battery.autoscan[0]
    @sensors = Ev3dev::Sensor.autoscan
    @tmotors = Ev3dev::TachoMotor.autoscan

    @connection.send(response_available_devices(AvailableDevices::NONE))
  end

  def decode message
    header = Integer(message[0...message.index('P')])
    payload = message[(message.index('P') + 1)..message.length]
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
      @info_updater.stop_all
      @connection.send(response_available_devices(device))
    when InboundFlags::DATA_RW
      read_write_data subcommand, device_type, device_id, payload
    when InboundFlags::REQUEST_UPDATE
    end
  end

  def encode response, device_type, device_id, payload
    message = response << 7
    message |= device_type << 3
    message |= device_id
    "#{message}P" + Marshal.dump(payload).force_encoding(Encoding::UTF_8)
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

  def read_write_data operation, device_type, device_id, data
    device_name = AvailableDevices::LOOKUP[device_type]
    begin
      rw_thread = Thread.new do
        case operation
        when InboundFlags::Internal::READ
          @connection.send(output_message("[READ - #{device_name} => #{device_id}] #{instance_variable_get("@#{device_name}")[device_id].send(data)}"))
        when InboundFlags::Internal::WRITE
          method, value = data.split(',').map(&:trim)
          instance_variable_get("@#{device_name}")[device_id].send("#{method}=", value)
        else
          raise "Wrong operation type"
        end
      end
      rw_thread.abort_on_exception = true
    rescue Exception => e
      @connection.send(error_message("On read-write operation: #{e}"))
    end
  end

  def error_message message
    encode(OutboundFlags::CONSOLE_ERROR, 0, 0, message)
  end

  def output_message message
    encode(OutboundFlags::CONSOLE_OUTPUT, 0, 0, message)
  end
end
