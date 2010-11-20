
spec = Gem::Specification.new do |s|
  s.name = "namespace"
  s.version = '1.0'
  s.homepage = 'https://github.com/zimbatm/namespace.rb'
  s.summary = 'Bringing namespaces to Ruby'
  s.description = 'This module is a hack that allows you to load specific
ruby files in the context of a Module, thus avoiding global namespace 
pollution'
  s.author = 'Jonas Pfenniger'
  s.email = 'jonas@pfenniger.name'
  s.files = ['README.md', 'lib/namespace.rb']
  s.require_paths = ["lib"]
end
