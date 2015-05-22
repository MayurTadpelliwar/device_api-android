# Encoding: utf-8
require 'open3'
require 'ostruct'
require 'device_api/execution'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # Android component of DeviceAPI
  module Android
    # Namespace for all methods encapsulating aapt calls
    class AAPT < DeviceAPI::Execution

      # Check to ensure that aapt has been setup correctly and is available
      # @return (Boolean) true if aapt is available, false otherwise
      def self.aapt_available?
        result = execute('which aapt')
        result.exit == 0
      end

      # Gets properties from the apk and returns them in a hash
      # @param apk path to the apk
      # @return (Hash) list of properties from the apk
      def self.get_app_props(apk)
        raise StandardError.new('aapt not found - please create a symlink in $ANDROID_HOME/tools') unless aapt_available?
        result = execute("aapt dump badging #{apk}")

        fail result.stderr if result.exit != 0

        lines = result.stdout.split("\n")
        results = []
        lines.each do |l|
          if /(.*): (.*)/.match(l)
            # results.push(Regexp.last_match[1].strip => Regexp.last_match[2].strip)
            values = {}

            Regexp.last_match[2].strip.split(' ').each do |item| # split on an spaces
              item = item.to_s.tr('\'', '') # trim off any excess single quotes
              values[item.split('=')[0]] = item.split('=')[1] # split on the = and create a new hash
            end

            results << {Regexp.last_match[1].strip => values} # append the result tp new_result

          end
        end
        results
      end

    end
  end
end
