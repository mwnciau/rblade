Gem::Specification.new do |s|
  s.name = "RBlade"
  s.version = "0.0.0"
  s.summary = "A port of the Laravel blade templating engine to ruby"
  s.description = "A port of the Laravel blade templating engine to ruby"
  s.authors = ["Simon J"]
  s.email = "2857218+mwnciau@users.noreply.github.com"
  s.files = ["lib/rblade.rb"]
  s.homepage = "https://rubygems.org/gems/rblade"
  s.license = "MIT"

  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "standard"
  s.add_development_dependency "rails", ">= 7.0"
end
