require_relative 'common'

class InfoUpdater
  def initialize
    @ports_thread = []
    @leds_thread = []
    @battery_thread = nil
    @sensors_thread = []
    @tmotors_thread = []
  end

  def update device_type, device_id, &block
    case device_type
    when AvailbaleDevices::NONE
      raise "Can't start device none"
    when AvailableDevices::SOUND, AvailableDevices::DISPLAY, AvailableDevices::SMOTOR, AvailableDevices::DMOTOR
      raise "Not implemented"
    when AvailableDevices::BATTERY
      @battery = Thread.new (block) { |exec| loop { exec.call } }
    else
      instance_variable_get("@#{AvailableDevices::LOOKUP[device_type]}_thread")[device_id] = Thread.new (block) { |exec| loop { exec.call } }
    end
    true
  end

  def stop device_type, device_id
    case device_type
    when AvailbaleDevices::NONE
      raise "Can't stop device none"
    when AvailableDevices::SOUND, AvailableDevices::DISPLAY, AvailableDevices::SMOTOR, AvailableDevices::DMOTOR
      raise "Not implemented"
    when AvailableDevices::BATTERY
      @battery_thread&.kill
    else
      instance_variable_get("@#{AvailableDevices::LOOKUP[device_type]}_thread")[device_id]&.kill
    end
    true
  end

  def stop_all
    @ports_thread.each { |t| t&.kill }
    @leds_thread.each { |t| t&.kill }
    @battery_thread&.kill
    @sensors_thread.each { |t| t&.kill }
    @tmotors_thread.each { |t| t&.kill }
    true
  end
end
