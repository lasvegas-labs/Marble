require 'xcodeproj'

project_path = 'Marble.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Marble' }

# Function to add a file reference if it doesn't exist
def add_file_to_target(project, target, file_path, group_path_array)
  group = project.main_group
  group_path_array.each do |group_name|
    group = group.groups.find { |g| g.display_name == group_name || g.name == group_name } || group.new_group(group_name)
  end
  
  # Check if file is already in the project
  file_ref = group.files.find { |f| f.path == File.basename(file_path) }
  unless file_ref
    file_ref = group.new_file(file_path)
    target.add_file_references([file_ref])
    puts "Added #{file_path}"
  else
    puts "Already in project: #{file_path}"
  end
end

# Files to add
files_to_add = [
  { path: 'Marble/Features/Common/Orb/OrbConfiguration.swift', group: ['Marble', 'Features', 'Common', 'Orb'] },
  { path: 'Marble/Features/Common/Orb/OrbView.swift', group: ['Marble', 'Features', 'Common', 'Orb'] },
  { path: 'Marble/Features/Friction/Router/FrictionRoute.swift', group: ['Marble', 'Features', 'Friction', 'Router'] },
  { path: 'Marble/Features/Friction/Router/FrictionRouteBuilder.swift', group: ['Marble', 'Features', 'Friction', 'Router'] },
  { path: 'Marble/Features/Friction/ViewModel/FrictionViewModel.swift', group: ['Marble', 'Features', 'Friction', 'ViewModel'] },
  { path: 'Marble/Features/Friction/View/FrictionView.swift', group: ['Marble', 'Features', 'Friction', 'View'] },
  { path: 'Marble/Features/Friction/View/MarbleOrb.swift', group: ['Marble', 'Features', 'Friction', 'View'] }
]

files_to_add.each do |file_info|
  add_file_to_target(project, target, file_info[:path], file_info[:group])
end

project.save
puts "Saved project."
