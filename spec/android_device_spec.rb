require 'device_api/android/connected'
include RSpec

describe DeviceAPI::Android do

  describe '.devices' do

    ProcessStatusStub = Struct.new(:exitstatus)
    $STATUS_ZERO = ProcessStatusStub.new(0)

    it 'Returns an empty array when no devices are connected' do
      out = <<_______________________________________________________
    List of devices attached

_______________________________________________________
      allow(Open3).to receive(:capture3) { [out, '', $STATUS_ZERO] }
      expect(DeviceAPI::Android::Connected.devices).to eq([])
    end

    it "returns an array with a single item when there's one device attached" do
      out = <<_______________________________________________________
    List of devices attached
    SH34RW905290	device

_______________________________________________________
      allow(Open3).to receive(:capture3) { [out, '', $STATUS_ZERO] }

      devices = DeviceAPI::Android::Connected.devices

      expect(devices.count).to eq(1)
      expect(devices[0]).to be_a DeviceAPI::Android::Device
      expect(devices[0].serial).to eq('SH34RW905290')
      expect(devices[0].status).to eq(:ok)
    end
  end

  describe ".device" do

    it "Returns an object representing a device" do
      out = <<_______________________________________________________
    device
_______________________________________________________
      allow(Open3).to receive(:capture3) { [out, '', $STATUS_ZERO] }

      device = DeviceAPI::Android::Connected.device('SH34RW905290')
      expect(device).to be_a DeviceAPI::Android::Device
      expect(device.serial).to eq('SH34RW905290')
      expect(device.status).to eq(:ok)
    end

  end
end
