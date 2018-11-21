begin
  gem 'sequel'

  require 'sequel/honeycomb'
rescue Gem::LoadError
  warn 'sequel not detected, not enabling sequel-honeycomb'

  # some gems use the presence of the Sequel module to determine if Sequel is in
  # use by the application. If we can't require the gem then we need to remove
  # the constant that we define so that other gems don't make bad assumptions
  Object.send(:remove_const, "Sequel")
end
