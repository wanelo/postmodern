source 'https://rubygems.org'

# Specify your gem's dependencies in postmodern.gemspec
gemspec

group :development do
  gem 'rubocop'
end

group :test do
  gem 'rspec'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard', require: RUBY_PLATFORM.include?('darwin')
end
