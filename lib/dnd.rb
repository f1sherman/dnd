require "dnd/version"
require "optparse"
require "chronic_duration"

module Dnd
  def self.run
    options = {}

    OptionParser.new do |opts|
      opts.on "-d DURATION", "--duration DURATION", "Duration to enable Do Not Disturb" do |duration|
        options[:duration] = ChronicDuration.parse duration
      end
    end.parse!

    @end = Time.now + options[:duration]
    puts "Enabling Do Not Disturb until #{@end}"

    system "defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true"
    system "defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date '#{Time.now}'"
    system "killall NotificationCenter"

    daemonize
  end

  def self.daemonize
    Process.daemon

    while Time.now < @end
      sleep 60
    end

    system "defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false"
    system "killall NotificationCenter"
  end
end
