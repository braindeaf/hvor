require_relative "lib/hvor/version"

Gem::Specification.new do |spec|
  spec.name        = "hvor"
  spec.version     = Hvor::VERSION
  spec.authors     = [ "RobL" ]
  spec.email       = [ "robert.lacey@geniebelt.com" ]
  spec.homepage    = "https://github.com/robertlacey/hvor"
  spec.summary     = "Rails engine that imports IP2Location LITE CSV data and answers IP -> country_code lookups."
  spec.description = "Hvor is a mountable Rails engine providing an ActiveJob that downloads and imports " \
                      "IP2Location LITE CSV zip archives (IPv4 + IPv6 ranges mapped to country_code) into an " \
                      "IPRange model, a cached Hvor.lookup(ip) API, and a lightweight mounted JSON API for " \
                      "looking up an arbitrary IP or the requesting client's own IP."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.4"
  spec.add_dependency "rubyzip", "~> 2.3"
  spec.add_dependency "csv"

  spec.add_development_dependency "rspec-rails", "~> 7.0"
  spec.add_development_dependency "webmock", "~> 3.19"
  spec.add_development_dependency "sqlite3", "~> 2.0"
end
