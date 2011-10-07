
spec = Gem::Specification.new do |s|
  s.name = "namespace"
  s.version = '1.2'
  s.homepage = 'https://github.com/zimbatm/namespace.rb'
  s.summary = 'Ruby namespaces experiment'
  s.description = 'This module is an experiment to bring namespaces to ruby.
Each imported file is loaded in it\'s own context,thus avoiding global namespace 
pollution'
  s.author = 'Jonas Pfenniger'
  s.email = 'jonas@pfenniger.name'
  s.files = ['README.md', 'lib/namespace.rb'] + Dir['test/**/*.rb']
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
end
