# dependencies: gem install xcodeproj
# 
# invocation: ruby bumpVersion.rb
#
# This will increment the CFBundleVersion of all of the required targets by one
# 
require 'xcodeproj'
project_path = './openwallet.xcodeproj'
project = Xcodeproj::Project.open(project_path)

desiredTargets = ['openwallet', 'openwallet WatchKit Extension', 'openwallet WatchKit App', 'TodayExtension', 'NotificationServiceExtension', 'MessagesExtension']
targets = project.native_targets.select do |target|
  desiredTargets.include? target.name
end

currentVersion = nil
targets.each do |target|
  info_plist_path = target.build_configurations.first.build_settings["INFOPLIST_FILE"]
  plist = Xcodeproj::Plist.read_from_path(info_plist_path)
  if currentVersion == nil
    currentVersion = plist['CFBundleVersion']
  end
  plist['CFBundleVersion'] = (currentVersion.to_i + 1).to_s
  Xcodeproj::Plist.write_to_path(plist, info_plist_path)
end