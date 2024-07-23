Gem::Specification.new do |s|
  s.name = "rblade"
  s.version = "0.1.0"
  s.summary = "Blade templates for ruby"
  s.description = "A port of the Laravel blade templating engine to ruby"
  s.authors = ["Simon J"]
  s.email = "2857218+mwnciau@users.noreply.github.com"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|storage)/}) }
  s.require_paths = ["lib"]
  s.homepage = "https://rubygems.org/gems/rblade"
  s.license = "MIT"
  s.required_ruby_version = ">= 3.0.0"

  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "minitest-reporters", "~> 1.1"
  s.add_development_dependency "standard", "~> 1.3"
  s.add_development_dependency "rails", "~> 7.0"
end
