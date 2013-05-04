# -*- ruby encoding: utf-8 -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :doofus
Hoe.plugin :email
Hoe.plugin :gemspec2
Hoe.plugin :git
Hoe.plugin :rubyforge
Hoe.plugin :minitest
Hoe.plugin :travis

spec = Hoe.spec 'text-format' do
  developer('Austin Ziegler', 'austin@rubyforge.org')

  self.remote_rdoc_dir = '.'
  self.rsync_args << ' --exclude=statsvn/'

  self.history_file = 'History.rdoc'
  self.readme_file = 'README.rdoc'
  self.extra_rdoc_files = FileList["*.rdoc"].to_a
  self.licenses = ["MIT", "Artistic 2.0", "GPL-2"]

  dependency 'text-hyphen', '~> 1.0'

  self.extra_dev_deps << ['hoe-bundler', '~> 1.2']
  self.extra_dev_deps << ['hoe-doofus', '~> 1.0']
  self.extra_dev_deps << ['hoe-gemspec2', '~> 1.1']
  self.extra_dev_deps << ['hoe-git', '~> 1.5']
  self.extra_dev_deps << ['hoe-rubygems', '~> 1.0']
  self.extra_dev_deps << ['hoe-travis', '~> 1.2']
  self.extra_dev_deps << ['minitest', '~> 4.5']
  self.extra_dev_deps << ['rake', '~> 10.0']
end
