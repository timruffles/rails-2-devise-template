### STEPS and setup come first, all the actual runnable is below
def file_inject file, what, with, after = true
  gsub_file file, Regexp.new("(#{Regexp.quote(what)})"), (after ? "\\1#{with}" : "#{with}\\1")
end

def make_user config
  run('ruby script/generate devise User')
  config[:user_made] = true
end

def rpx_connect config
  config[:rpx_connect] = true
  # config.gem 'rpx_now'
  gem 'rpx_now'
  gem 'devise_rpx_connectable'
  
  rake 'gems:install'  
  
  # add app name
  puts "What is the name of your RPX app, the name, NOT the API key (you can change this in config/initializers/devise.rb @ config.rpx_application_name)"
  rpx_app_name = STDIN.gets.chomp
  file_inject 'config/initializers/devise.rb', "Devise.setup do |config|\n", "config.rpx_application_name = '#{rpx_app_name}'"
  
  # add api key
  puts "What is your RPX app API Key (you can change this in config/environment.rb in the config._adter_initialize block)"
  rpx_api_key = STDIN.gets.chomp
  
  rpx_api_key_include = <<-API
    config.after_initialize do # so rake gems:install works
      RPXNow.api_key = "#{rpx_api_key}"
    end
  API
  
  file_inject 'config/environment.rb', "Rails::Initializer.run do |config|\n", rpx_api_key_include
  
  # setup user if present
  if(config[:user_made]) 
    file = Dir.glob('db/migrate/*_devise_create_users.rb').first
    file_inject file, "create_table(:users) do |t|\n", "t.string :rpx_identifier\n"
  end
end

## ACTUAL runnable

gem 'warden'
gem 'devise', :version => '1.0.7'

rake 'gems:install'

config = {}

run('ruby script/generate devise_install')

make_user(config) if yes?("Do you want a basic user model?")
rpx_connect(config) if yes?("Do you want to use RPX with Devise?")


readme = <<-READ

== Devise#{" and RPX" if config[:rpx_connect]} have been added to the app using Tim Ruffles's template, available at y


This template is just an implementation of the readmes provided by the fantastic Devise team at

http://github.com/plataformatec/devise

and the team at devise_rpx_connectable

http://github.com/slainer68/devise_rpx_connectrable

Thanks to them for making it so easy to get an app with great auth up in minutes! :)

READ

file_inject 'README', "This directory is in the load path.\n", readme

