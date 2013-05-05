# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "text-format"
  s.version = "1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Ziegler"]
  s.cert_chain = ["/Users/AZiegler/.gem/gem-public_cert.pem"]
  s.date = "2013-05-05"
  s.description = "Text::Format is provides the ability to nicely format fixed-width text with\nknowledge of the writeable space (number of columns), margins, and indentation\nsettings. Text::Format can work with either TeX::Hyphen or Text::Hyphen to\nhyphenate words when formatting.\n\nThis is release 1.0, containing both feature enhancements and bug fixes over\nthe previous version, 0.64.\n\n:include: Contributing.rdoc\n\n:include: Licence.rdoc"
  s.email = ["austin@rubyforge.org"]
  s.extra_rdoc_files = ["Contributing.rdoc", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "TODO.rdoc", "docs/COPYING.txt", "docs/artistic.txt", "Contributing.rdoc", "History.rdoc", "Licence.rdoc", "README.rdoc", "TODO.rdoc"]
  s.files = [".gemtest", ".hoerc", ".travis.yml", "Contributing.rdoc", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "TODO.rdoc", "docs/COPYING.txt", "docs/artistic.txt", "lib/text/format.rb", "lib/text/format/alpha.rb", "lib/text/format/number.rb", "lib/text/format/roman.rb", "test/test_text_format.rb"]
  s.homepage = "http://text-format.rubyforge.org"
  s.licenses = ["MIT", "Artistic 2.0", "GPL-2"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "text-format"
  s.rubygems_version = "1.8.25"
  s.signing_key = "/Users/AZiegler/.gem/gem-private_key.pem"
  s.summary = "Text::Format is provides the ability to nicely format fixed-width text with knowledge of the writeable space (number of columns), margins, and indentation settings"
  s.test_files = ["test/test_text_format.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<text-hyphen>, ["~> 1.0"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<minitest>, ["~> 4.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe-bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>, ["~> 1.5"])
      s.add_development_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.6"])
    else
      s.add_dependency(%q<text-hyphen>, ["~> 1.0"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<minitest>, ["~> 4.7"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe-bundler>, ["~> 1.2"])
      s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>, ["~> 1.5"])
      s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<hoe>, ["~> 3.6"])
    end
  else
    s.add_dependency(%q<text-hyphen>, ["~> 1.0"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<minitest>, ["~> 4.7"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe-bundler>, ["~> 1.2"])
    s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>, ["~> 1.5"])
    s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
    s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<hoe>, ["~> 3.6"])
  end
end
