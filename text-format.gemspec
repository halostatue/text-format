# -*- encoding: utf-8 -*-
# stub: text-format 1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "text-format".freeze
  s.version = "1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/halostatue/text-format/issues", "homepage_uri" => "http://text-format.rubyforge.org", "source_code_uri" => "https://github.com/halostatue/text-format" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2022-09-29"
  s.description = "Text::Format is provides the ability to nicely format fixed-width text with\nknowledge of the writeable space (number of columns), margins, and indentation\nsettings. Text::Format can work with Text::Hyphen to hyphenate words when\nformatting.\n\nThis is release 1.0, containing both feature enhancements and bug fixes over\nthe previous version, 0.64.\n\n:include: Contributing.rdoc\n\n:include: Licence.rdoc".freeze
  s.email = ["austin@rubyforge.org".freeze]
  s.extra_rdoc_files = ["Contributing.rdoc".freeze, "History.rdoc".freeze, "Licence.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "TODO.rdoc".freeze, "docs/COPYING.txt".freeze, "docs/artistic.txt".freeze, "Contributing.rdoc".freeze, "History.rdoc".freeze, "Licence.rdoc".freeze, "README.rdoc".freeze, "TODO.rdoc".freeze]
  s.files = [".gemtest".freeze, ".hoerc".freeze, ".travis.yml".freeze, "Contributing.rdoc".freeze, "History.rdoc".freeze, "Licence.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "TODO.rdoc".freeze, "docs/COPYING.txt".freeze, "docs/artistic.txt".freeze, "lib/text/format.rb".freeze, "lib/text/format/alpha.rb".freeze, "lib/text/format/number.rb".freeze, "lib/text/format/roman.rb".freeze, "test/test_text_format.rb".freeze]
  s.homepage = "http://text-format.rubyforge.org".freeze
  s.licenses = ["MIT".freeze, "Artistic 2.0".freeze, "GPL-2".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.3.7".freeze
  s.summary = "Text::Format is provides the ability to nicely format fixed-width text with knowledge of the writeable space (number of columns), margins, and indentation settings".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<text-hyphen>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.16"])
    s.add_development_dependency(%q<hoe-bundler>.freeze, ["~> 1.2"])
    s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
    s.add_development_dependency(%q<rake>.freeze, ["< 14"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.25"])
  else
    s.add_dependency(%q<text-hyphen>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.16"])
    s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.2"])
    s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>.freeze, ["~> 1.5"])
    s.add_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
    s.add_dependency(%q<rake>.freeze, ["< 14"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.25"])
  end
end
