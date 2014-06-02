require "bundler/gem_tasks"

rake :permissions do
  Dir['lib/**/*.rb'].each do |f|
    File.chmod(755, f)
  end
end

rake :release => :permissions
