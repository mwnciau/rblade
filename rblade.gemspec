Gem::Specification.new do |s|
  s.name = "rblade"
  s.version = "0.0.0"
  s.summary = "A port of the Laravel blade templating engine to ruby"
  s.description = "A port of the Laravel blade templating engine to ruby"
  s.authors = ["Simon J"]
  s.email = "2857218+mwnciau@users.noreply.github.com"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|storage)/}) }
  s.require_paths = ['lib']
  s.homepage = "https://rubygems.org/gems/rblade"
  s.license = "MIT"

  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "standard"
  s.add_development_dependency "rails", "~> 7.0"
end
