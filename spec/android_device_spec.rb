require 'spec_helper'
require 'device_api/android'

describe DeviceAPI::Android do

  describe '.devices' do

    it 'Returns an empty array when no devices are connected' do
      out = <<_______________________________________________________
List of devices attached

_______________________________________________________
      allow(Open3).to receive(:capture3) { [out, '', STATUS_OK] }
      expect(DeviceAPI::Android.devices).to eq([])
    end

    it "returns an array with a single item when there's one device attached" do
      out = <<_______________________________________________________
List of devices attached
SH34RW905290	device

_______________________________________________________
      allow(Open3).to receive(:capture3) { [out, '', STATUS_OK] }

      devices = DeviceAPI::Android.devices

      expect(devices.count).to eq(1)
      expect(devices[0]).to be_a DeviceAPI::Android::Device
      expect(devices[0].serial).to eq('SH34RW905290')
      expect(devices[0].status).to eq(:ok)
    end

    it 'handles an untrusted device correctly' do
      out = <<eof
List of devices attached
G090G8105387008L	unauthorized
eof
      allow(Open3).to receive(:capture3) { [out, '', STATUS_OK] }

      devices = DeviceAPI::Android.devices
      expect(devices.count).to eq(1)
      expect(devices[0]).to be_a DeviceAPI::Android::Device
      expect(devices[0].serial).to eq('G090G8105387008L')
      expect(devices[0].status).to eq(:unauthorized)
    end
  end

  describe ".device" do

    it "Returns an object representing a device" do
      out = <<_______________________________________________________
    device
_______________________________________________________
      allow(Open3).to receive(:capture3) { [out, '', STATUS_OK] }

      device = DeviceAPI::Android.device('SH34RW905290')
      expect(device).to be_a DeviceAPI::Android::Device
      expect(device.serial).to eq('SH34RW905290')
      expect(device.status).to eq(:ok)
    end

  end
end
