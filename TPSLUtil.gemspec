# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "TPSLUtil/version"

Gem::Specification.new do |s|
  s.name        = "TPSLUtil"
  s.version     = Tpslutil::VERSION
  s.authors     = "ASCENT IT SOLUTIONS"
  s.email       = "k.pande@ascentsol.com"
  s.homepage    = "http://www.ascentsol.com"
  s.summary     = "Checksum Integration"
  s.description = "Used to process request as well as response and verify the transaction using checksum method"

  s.rubyforge_project = "TPSLUtil"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
