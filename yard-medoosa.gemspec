Gem::Specification.new do |s|
  s.name        = "yard-medoosa"
  s.version     = File.read("VERSION").strip
  s.summary     = "YARD class diagrams"
  s.description = "Enhance YARD documentation by generating class diagrams."
  s.authors     = ["Martin Vidner"]
  s.email       = "martin@vidner.net"
  s.homepage    = "https://rubygems.org/gems/yard-medoosa"
  s.license     = "MIT" # like YARD

  s.files       = [
    "bin/yard-medoosa",
    "lib/yard-medoosa.rb"
  ]
  s.executables = s.files.grep(/^bin\//) { |f| File.basename(f) }

  s.add_runtime_dependency "graphviz", "~> 1"
end
