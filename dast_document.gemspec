Gem::Specification.new do |s|
  s.name        = 'dast_document'
  s.version     = '0.0.1'
  s.summary     = "DatoCMS structured document"
  s.description = "Simple gem to generate some HTML from the Dato Structure Text field"
  s.authors     = ["Kevin Pratt"]
  s.email       = 'kevin@paradem.co'
  s.files       = ["lib/dast_document.rb"]
  s.homepage    =
    'https://rubygems.org/gems/dast_document'
  s.license       = 'MIT'

  s.add_runtime_dependency 'nokogiri', '>= 1.13.4'
end
