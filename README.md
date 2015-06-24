Capifony MultiStage Setup For Kunstmaan Bundles CMS
===========================

Read the official docs: http://capifony.org/

- The configuration provided here sets your default stage as 'staging', with another stage called 'production'. (Go figure.)

The configuration herein follows this deployment workflow:

- After cloning the latest push on your server:
- It will copy your vendors directory contents from the last release to the current release, then attempts a 'composer install' based on the newest lock file. It will never run 'composer update'.
- It shares the app/logs, app/Resources/node_modules, web/uploads, and web/vendor (bower dependencies) from the last release to the current release.
- It symlinks the app/Resources/node_modules from the previous release to the current release, then attempts an 'npm install'
- It calls assetic:dump
- It calls assets:install
- It updates the assets_version string in config.yml
- It runs in interactive mode, when you run 'deploy:migrations', or any symfony console command that requires interaction
- If the parameters.yml file is empty, it writes a basic 'parameters:' string to the app/config/parameters.yml file, so the composer install won't fail horrifically

Entering Maintenance Mode
-------------------

Add this to your apache configuration for your site to force a redirect to the maintenance.html file 

```conf
# Vhost/Apache config
<IfModule mod_rewrite.c>
			RewriteEngine On
			ErrorDocument 503 /maintenance.html
      RewriteCond %{REQUEST_URI} !\.(css|gif|jpg|png)$
		  RewriteCond %{DOCUMENT_ROOT}/maintenance.html -f
		  RewriteCond %{SCRIPT_FILENAME} !maintenance.html
		  RewriteRule ^.*$  -  [redirect=503,last]
		        
			# Symfony mod_rewrite stuff hereafter...
</IfModule>
```

Run the following from your deployment source:

```bash
cap deploy:web:disable
```

This will upload a maintenance.html file to your web directory, with the default reason, and current time.

For more information: https://github.com/tvdeyen/capistrano-maintenance


Assumptions
-------------------

1. You're using SpBowerBundle (https://github.com/Spea/SpBowerBundle), to manage your Bower dependencies, with a configuration similar to:

```yaml
sp_bower:
    install_on_warmup: false
    keep_bowerrc: true
    offline: false
    allow_root: false
    assetic:
        enabled: false
    bundles:
        MySiteBundle:
            config_dir: %kernel.root_dir%/Resources
            # This is the important setting, as the default config assumes this is your Bower vendor directory!!
            asset_dir: %kernel.root_dir%/../web/vendor
            json_file: component.json
            cache:
                id: ~
                directory: %kernel.cache_dir%/bower
```

2. Your staging server deployments will come from your repository's 'develop' branch; production server deployments will come from your 'master' branch. You can change both of those in app/config/deploy/{staging.rb, production.rb}.

3. You use the 'remote_cache' deployment model (see above link for differentiation).

Gems
-------------------

You'll need the following Ruby Gems:

capifony (2.3.0)
capistrano (2.15.5)
capistrano-maintenance (0.0.3)
colored (1.2)
highline (1.7.2)
inifile (3.0.0)
net-scp (1.2.1)
net-sftp (2.1.2)
net-ssh (2.9.2)
net-ssh-gateway (1.2.0)
ruby-progressbar (1.0.2)

Which all should be installed when you run:

```bash
gem install capifony -v2.3.0
```

Server Setup (Live & Staging)
----------------

From your deployment source:

```bash
cap <stage_name> deploy:setup
```

This will run a custom task called 'upload_parameters', in the 'deploy' namespace. It will upload the app/config/parameters/parameters_<stage_name>.yml to the proper place.

Permissions on Servers
------------------

To ensure proper permissions for both the webserver user as well as your deployment user, the following commands should be run from your website root directory:

```bash
chown -R apache:<deployer> shared/app/logs shared/web/uploads # Ensures deployment user has proper permissions to execute setfacl calls
chmod g+ws shared/app/logs shared/web/uploads # Makes logs group-writeable, group-sticky for new logs created
setfacl -R -m u:apache:rwX -m u:<deployer>:rwX app/cache app/logs web/uploads # Basic SF2 stuff
setfacl -dR -m u:apache:rwX -m u:<deployer>:rwX app/cache app/logs web/uploads #Basic SF2 stuff
```

Parameter files
----------------

app/config/parameters/parameters_staging.yml - Holds your staging server parameters
app/config/parameters/parameters_production.yml - Holds your production server parameters

Some values can be populated, and stored in VCS, others, you will need access to your server(s) to add the proper values. (ie. db credentials).

Deployment
----------------

Initial setup aside, deploying your current pushed commit to either stage goes something along the lines of:

```bash
cap <stage_name> deploy:web:disable
cap <stage_name> deploy -v 
# Or, if you have pending migrations, this will prompt you interactively at the right points
cap <stage_name> deploy:migrations
```

Todo
----------------
- The app/cache directory should be shared as well (or at least the session_dir)



