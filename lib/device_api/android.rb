# Encoding: utf-8
require 'device_api/android/adb'
require 'device_api/android/device'
require 'device_api/android/signing'

# Load plugins
require 'device_api/android/plugins/audio'
require 'device_api/android/plugins/memory'
require 'device_api/android/plugins/battery'
require 'device_api/android/plugins/disk'

# Load additional device types
require 'device_api/android/device/kindle'
require 'device_api/android/device/samsung'

module DeviceAPI
  module Android
    # Returns array of connected android devices
    def self.devices
      ADB.devices.map do |d|
        if d.keys.first && !d.keys.first.include?('?')
          DeviceAPI::Android::Device.create( self.get_device_type(d), { serial: d.keys.first, state: d.values.first } )
        end
      end.compact
    end

    # Retrieve an Device object by serial id
    def self.device(serial)
      if serial.to_s.empty?
        raise DeviceAPI::BadSerialString.new("serial was '#{serial.nil? ? 'nil' : serial}'")
      end
      state = ADB.get_state(serial)
      DeviceAPI::Android::Device.create( self.get_device_type({ :"#{serial}" => state}),  { serial: serial, state: state })
    end

    # Return the device type used in determining which Device Object to create
    def self.get_device_type(options)
      return :default if options.values.first == 'unauthorized'
      begin
        man = Device.new(serial: options.keys.first, state: options.values.first).manufacturer
      rescue DeviceAPI::DeviceNotFound
        return :default
      rescue => e
        puts "Unrecognised exception whilst finding device '#{options.keys.first}' (state: #{options.values.first})"
        puts e.message
        puts e.backtrace.inspect
        return :default
      end
      return :default if man.nil?
      case man.downcase
        when 'amazon'
          type = :kindle
        when 'samsung'
          type = :samsung
        else
          type = :default
      end
      type
    end
  end

  # Serial error class
  class BadSerialString < StandardError
  end
end
