Gem::Specification.new do |s|
  s.name = "rblade"
  s.version = "2.0.2"
  s.summary = "A component-first templating engine for Rails"
  s.description = "RBlade is a simple, yet powerful templating engine for Ruby on Rails, inspired by Laravel Blade."
  s.authors = ["Simon J"]
  s.email = "2857218+mwnciau@users.noreply.github.com"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|storage)/}) }
  s.require_paths = ["lib"]
  s.homepage = "https://rubygems.org/gems/rblade"
  s.metadata = {"source_code_uri" => "https://github.com/mwnciau/rblade"}
  s.license = "MIT"
  s.required_ruby_version = ">= 3.0.0"

  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "minitest-reporters", "~> 1.1"
  s.add_development_dependency "standard", ">= 1.3"
  s.add_development_dependency "rails", ">= 7.0"
end
