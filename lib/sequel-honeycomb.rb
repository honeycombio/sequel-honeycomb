begin
  gem 'sequel'

  require 'sequel/honeycomb'
rescue Gem::LoadError
  warn 'sequel not detected, not enabling sequel-honeycomb'
end
