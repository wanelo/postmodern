source 'https://rubygems.org'

# Specify your gem's dependencies in postmodern.gemspec
gemspec

group :development do
  gem 'rubocop'
  gem 'pry-nav'
end

group :test do
  gem 'rspec'
  gem 'aruba-rspec'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard', require: RUBY_PLATFORM.include?('darwin')
end
