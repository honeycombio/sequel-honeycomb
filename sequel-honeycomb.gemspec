lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH << lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name = 'sequel-honeycomb'
  gem.version = File.read("VERSION").strip

  gem.summary = 'Instrument your Sequel queries with Honeycomb'
  gem.description = <<-DESC
    TO DO *is* a description
  DESC

  gem.authors = ['Sam Stokes']
  gem.email = %w(support@honeycomb.io)
  gem.homepage = 'https://github.com/honeycombio/sequel-honeycomb'
  gem.license = 'Apache-2.0'


  gem.add_dependency 'libhoney'

  gem.add_development_dependency 'sequel'
  gem.add_development_dependency 'bump'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'yard'

  gem.files = Dir[*%w(
      lib/**/*
      README*)] & %x{git ls-files -z}.split("\0")
end
