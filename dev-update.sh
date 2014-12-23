set -o nounset
set -o errexit

while read -r dir; do

	if [ ! -f $dir/wp-config.php ]; then
		continue
	fi

	echo "Site found: $dir"

	# Maybe update all WP cores
	wp core update --path=$dir
	wp core update-db --path=$dir

	# Update all plugins
	wp plugin update-all --path=$dir

	# Update all themes
	wp theme update-all --path=$dir

	# Delete spam comments
	wp comment delete --path=$dir $(wp comment list --status=spam --field=ID --path=$dir)

	# Flush all WP caches
	wp cache flush --path=$dir

	# Flush all WP rewrites
	wp rewrite flush --path=$dir

	# Cleanup DB
	wp db repair --path=$dir
	wp db optimize --path=$dir

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
			# exit 1
			;;
		esac
		shift
	done

done < <(find ~/Sites -type d -maxdepth 1)




while read -r dir; do

	if [ ! -f $dir/wp-config.php ]; then
		continue
	fi

	echo "Site found: $dir"

	# Maybe update all WP cores
	wp core update --path=$dir
	wp core update-db --path=$dir

	# Update all plugins
	wp plugin update-all --path=$dir

	# Update all themes
	wp theme update-all --path=$dir

	# Delete spam comments
	wp comment delete --path=$dir $(wp comment list --status=spam --field=ID --path=$dir)

	# Flush all WP caches
	wp cache flush --path=$dir

	# Flush all WP rewrites
	wp rewrite flush --path=$dir

	# Cleanup DB
	wp db repair --path=$dir
	wp db optimize --path=$dir

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
			# exit 1
			;;
		esac
		shift
	done

done < <(find ~/Sites -type d -maxdepth 1)

# Update all submodules
find ~/Documents -type d -name '.git' -exec sh -c 'cd "{}" && cd .. && git submodule foreach git pull origin master' \;

# Update all Bower dependencies
find ~/Documents -type d -name 'bower_components' -exec sh -c 'cd "{}" && cd .. && bower update --save' \;

# Update all Composer dependencies
find ~/Documents -type d -name 'vendor' -exec sh -c 'cd "{}" && cd .. && composer update' \;

# Update NPM
find ~/Documents -type d -name 'node_modules' -exec sh -c 'cd "{}" && cd .. && npm update --save-dev' \;
