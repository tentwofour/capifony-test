# Set the proper parameters file
set :parameters_file, "parameters_production.yml"

set :domain,        "your.livefqdn.com"

server              domain, :app, :web, :primary => true

set :user,          "productiondeployer"
set :deploy_to,     "/var/www/html/mysite"
set :deploy_via,    :remote_cache
set :branch,        "master"

role :web,          domain
role :app,          domain, :primary => true
role :db,           domain, :primary => true

# Webserver user and permissions, writeable dirs is set in main deploy.rb script
set :webserver_user,        "apache"
set :permission_method,     :acl
set :use_set_permissions,   true