source 'https://rubygems.org'

# Specify your gem's dependencies in postmodern.gemspec
gemspec

group :development do
  gem 'rubocop'
  gem 'pry-nav'
end

group :test do
  gem 'rspec', '>= 3.0.0'
  gem 'aruba-rspec', '>= 1.0.0'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'timecop'
  gem 'terminal-notifier-guard', require: RUBY_PLATFORM.include?('darwin')
end
