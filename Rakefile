require "bundler/gem_tasks"

task :permissions do
  Dir['lib/**/*.rb'].each do |f|
    File.chmod(0755, f)
  end
end

task :release => :permissions
