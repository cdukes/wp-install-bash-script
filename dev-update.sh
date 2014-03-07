# Update all WP cores
find ~/Sites -type d -maxdepth 1 -exec wp core update --path={} \;
find ~/Sites -type d -maxdepth 1 -exec wp core update-db --path={} \;

# Update all plugins
find ~/Sites -type d -maxdepth 1 -exec wp plugin update-all --path={} \;

# Update all themes
find ~/Sites -type d -maxdepth 1 -exec wp theme update-all --path={} \;

# Update all submodules
find ~/Documents -type d -name '.git' -exec sh -c 'cd "{}" && cd .. && git submodule foreach git pull origin master' \;

# Update all Bower dependencies
find ~/Documents -type d -name 'bower_components' -exec sh -c 'cd "{}" && cd .. && bower update --save' \;

# Update NPM
find ~/Documents -type d -name 'node_modules' -exec sh -c 'cd "{}" && cd .. && npm update --save-dev' \;

# Flush all WP caches
find ~/Sites -type d -maxdepth 1 -exec wp cache flush --path={} \;

# Flush all WP rewrites
find ~/Sites -type d -maxdepth 1 -exec wp rewrite flush --path={} \;

# Regenerate all thumbnails
find ~/Sites -type d -maxdepth 1 -exec wp media regenerate --path={} \;