# frozen_string_literal: true

require_relative "lib/dast_document/version"

Gem::Specification.new do |spec|
  spec.name = "dast_document"
  spec.version = DastDocument::VERSION
  spec.authors = ["Kevin Pratt"]
  spec.email = ["kevin@paradem.co"]

  spec.summary = "DatoCMS structured document"
  spec.description = "A class that will render out a DatoCMS dast document to HTML"
  spec.homepage = "https://github.com/paradem/dast_document"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/paradem/dast_document"
  spec.metadata["changelog_uri"] = "https://github.com/paradem/dast_document/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri", ">= 1.13.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
