# -*- ruby encoding: utf-8 -*-

require "rubygems"
require "hoe"

Hoe.plugin :doofus
Hoe.plugin :email
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :minitest
Hoe.plugin :travis

spec = Hoe.spec "text-format" do
  developer("Austin Ziegler", "halostatue@gmail.com")

  self.history_file = "History.rdoc"
  self.readme_file = "README.rdoc"
  self.extra_rdoc_files = FileList["*.rdoc"].to_a
  self.licenses = ["MIT", "Artistic 2.0", "GPL-2"]

  dependency "text-hyphen", "~> 1.0"

  extra_dev_deps << ["hoe-bundler", "~> 1.2"]
  extra_dev_deps << ["hoe-doofus", "~> 1.0"]
  extra_dev_deps << ["hoe-gemspec2", "~> 1.1"]
  extra_dev_deps << ["hoe-git", "~> 1.5"]
  extra_dev_deps << ["hoe-rubygems", "~> 1.0"]
  extra_dev_deps << ["hoe-travis", "~> 1.2"]
  extra_dev_deps << ["minitest", "~> 4.5"]
  extra_dev_deps << ["rake", "<14"]
end
