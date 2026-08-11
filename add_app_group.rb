require 'xcodeproj'

project_path = 'Marble.xcodeproj'
project = Xcodeproj::Project.open(project_path)
app_group_id = 'group.com.lasvegas.Marble'

# Generate Entitlements files
['Marble', 'MarbleShieldConfiguration', 'MarbleShieldAction'].each do |target_name|
  entitlements_path = "#{target_name}/#{target_name}.entitlements"
  
  content = ""
  if File.exist?(entitlements_path)
    content = File.read(entitlements_path)
  else
    content = %Q{<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>}
  end
  
  unless content.include?('com.apple.security.application-groups')
    insertion = %Q{
	<key>com.apple.security.application-groups</key>
	<array>
		<string>#{app_group_id}</string>
	</array>}
    content.sub!('<dict>', "<dict>" + insertion)
    File.write(entitlements_path, content)
  end
  
  # Ensure the target points to the entitlements file in build settings
  target = project.targets.find { |t| t.name == target_name }
  if target
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGN_ENTITLEMENTS'] = entitlements_path
    end
  end
end

project.save
