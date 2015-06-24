set :parameters_file, "parameters_staging.yml"

set :domain,        "your.stagingfqdn.com"

server              domain, :app, :web, :primary => true

# user needs access to git repo
set :user,          "stagingdeployer"
set :deploy_to,     "/var/www/html/mysite"
set :branch,		"develop"

role :web,          domain
role :app,          domain, :primary => true
role :db,           domain, :primary => true

# Webserver user and permissions, writeable dirs is set in main deploy.rb script
set :webserver_user,        "apache"
set :permission_method,     :acl
set :use_set_permissions,   true