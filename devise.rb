gem 'thor'
gem 'warden'
gem 'devise', :version => '1.0.7'

rake 'gems:install'

inject_into_file 'README', '=== With added userness from a template', :after => "== Welcome to Rails\n", :verbose => true