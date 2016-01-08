set -o nounset

while read -r dir; do

	if [ ! -f $dir/wp-config.php ]; then
		continue
	fi

	echo "Site found: $dir"

	# Maybe update all WP cores
	wp core update --path=$dir
	wp core update-db --path=$dir

	# Update all plugins
	wp plugin update --all --path=$dir

	# Update all themes
	wp theme update --all --path=$dir

	# Delete spam comments
	if [ "$(wp comment list --status=spam --format=count --path=$dir)" -gt 0 ]; then
		wp comment delete $(wp comment list --status=spam --format=ids --path=$dir) --path=$dir
	fi

	# Flush all WP caches + transients
	wp cache flush --path=$dir
	# wp transient delete-all --path=$dir
	wp transient delete-expired --path=$dir

	# Flush all WP rewrites
	wp rewrite flush --path=$dir

	# Cleanup DB
	# wp db repair --path=$dir
	# wp db optimize --path=$dir

	# Reset permissions
	echo "Resetting permissions"
	find $dir -type d -exec chmod -R 775 {} \;
	find $dir -type f -exec chmod -R 664 {} \;

	# Optional
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--regenerate-thumbnails|-R)
			# Regenerate all thumbnails
			wp media regenerate --yes --path=$dir \;
			shift
			;;
		--clear-all-transients|-Ta)
			# Clear WP transients
			wp transient delete-all --path=$dir \;
			shift
			;;
		--clear-expirated-transients|-Te)
			# Clear expired WP transients
			wp transient delete-expired --path=$dir \;
			shift
			;;
		*)
			echo "Invalid option: $1"
			shift
			;;
		esac
	done
	# Test cron
	wp cron test --path=$dir

done < <(find ~/Sites -type d -maxdepth 1)

# Update all submodules
find ~/Documents -type d -name '.git' -exec sh -c 'cd "{}" && cd .. && git submodule foreach git pull origin master' \;

# Update all Bower dependencies
find ~/Documents -type d -name 'bower_components' -exec sh -c 'cd "{}" && cd .. && bower update --save' \;

# Update all Composer dependencies
find ~/Documents -type d -name 'vendor' -exec sh -c 'cd "{}" && cd .. && composer update' \;

# Update NPM
find ~/Documents -type d -name 'node_modules' -exec sh -c 'cd "{}" && cd .. && npm update --save-dev' \;
