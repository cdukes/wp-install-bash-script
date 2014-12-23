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

# Delete spam comments
wp comment delete $(wp comment list --status=spam --field=ID)

# Flush all WP caches
find ~/Sites -type d -maxdepth 1 -exec wp cache flush --path={} \;

# Flush all WP rewrites
find ~/Sites -type d -maxdepth 1 -exec wp rewrite flush --path={} \;

# Cleanup DB
wp db repair
wp db optimize

# Optional
while [[ $# -gt 0 ]]; do
	case "$1" in
	--regenerate-thumbnails|-R)
		# Regenerate all thumbnails
		find ~/Sites -type d -maxdepth 1 -exec wp media regenerate --yes --path={} \;
		shift
		;;
	--clear-all-transients|-Ta)
		# Clear WP transients
		find ~/Sites -type d -maxdepth 1 -exec wp transient delete-all --path={} \;
		shift
		;;
	--clear-expirated-transients|-Te)
		# Clear expired WP transients
		find ~/Sites -type d -maxdepth 1 -exec wp transient delete-expired --path={} \;
		shift
		;;
	*)
		echo "Invalid option: $1"
		# exit 1  ## Could be optional.
		;;
	esac
	shift
done
