set -o nounset
set -o errexit

# get variables
SITENAME=$1
. "$(dirname "$0")"/wp-setup-config.sh

# create and enter folder
cd ~/Sites
mkdir $SITENAME.t
cd $SITENAME.t

# create DB
mysql -h localhost -u $DB_USER -Bse "CREATE DATABASE $SITENAME; "

# download and install WP
wp core download
wp core config --dbname=$SITENAME --dbuser=$DB_USER --dbpass=$DB_PW --dbhost=$DB_HOST --skip-check
wp core install --url=https://$SITENAME.t.test --title=$SITENAME --admin_user=$WP_USER --admin_password=$WP_PW --admin_email=$WP_EMAIL --skip-email

# configure WP
wp config set WP_SITEURL https://$SITENAME.t.test
wp config set WP_HOME https://$SITENAME.t.test
wp config set WP_POST_REVISIONS false --raw
wp config set WP_DISABLE_FATAL_ERROR_HANDLER true --raw
wp config set WP_DEBUG true --raw
wp config set WP_DEBUG_LOG false --raw
wp config set WP_DEBUG_DISPLAY true --raw
wp config set WP_ENVIRONMENT_TYPE local
wp config set WP_DEVELOPMENT_MODE theme
# wp config set SCRIPT_DEBUG true --raw
# wp config set CONCATENATE_SCRIPTS false --raw
wp config set WP_MEMORY_LIMIT 256M
wp config set WP_MAX_MEMORY_LIMIT 256M
wp config set CORE_UPGRADE_SKIP_NEW_BUNDLED true --raw
wp config set WP_AUTO_UPDATE_CORE minor
wp config set DISALLOW_FILE_EDIT true --raw
wp config set FORCE_SSL_ADMIN true --raw
wp config set WP_DEFAULT_THEME genesis
wp config set ALLOW_UNFILTERED_UPLOADS true --raw

# install plugins
wp plugin uninstall akismet
wp plugin uninstall hello
wp plugin install "$WP_ACF_LOCATION" --activate
wp plugin install better-search-replace
wp plugin install classic-editor
# wp plugin install co-authors-plus
wp plugin install disable-blog
wp plugin install disable-comments --activate
wp plugin install disable-embeds --activate
wp plugin install disable-emojis --activate
wp plugin install disable-json-api --activate
wp plugin install duplicate-post --activate
wp plugin install enable-media-replace
wp plugin install ewww-image-optimizer
wp plugin install forbid-pwned-passwords --activate
wp plugin install image-processing-queue --activate
wp plugin install imsanity --activate
wp plugin install limit-login-attempts-reloaded --activate
# wp plugin install query-monitor
wp plugin install redirection
wp plugin install regenerate-thumbnails
wp plugin install wordpress-seo --activate

# MU plugins
wp plugin install password-bcrypt
wp eval 'mkdir(WP_CONTENT_DIR . "/mu-plugins/");'
wp eval 'rename(WP_CONTENT_DIR . "/plugins/password-bcrypt/wp-password-bcrypt.php", WP_CONTENT_DIR . "/mu-plugins/wp-password-bcrypt.php");'
rm -rf wp-content/plugins/password-bcrypt

# cleanup themes
wp theme install "$WP_GENESIS_LOCATION" --activate
wp theme delete twentytwentyfour
wp theme delete twentytwentythree
wp theme delete twentytwentytwo

# empty site content
wp site empty --yes

# add test XML
while [[ $# -gt 0 ]]; do
	case "$1" in
	--install-test-content|-T)
		curl -O https://raw.github.com/manovotny/wptest/master/wptest.xml
		wp import wptest.xml --authors=create
		rm wptest.xml
		shift
		;;
	*)
		echo "Invalid option: $1"
		# exit 1
		;;
	esac
	shift
done

# clean db
wp cache flush
wp transient delete --all

# flush permalinks
wp rewrite structure '/%postname%/' --hard

# update site options
wp option update blogdescription ''
wp option update blog_public '0'
wp option update default_ping_status 'closed'
wp option update default_comment_status 'closed'
wp option update image_default_link_type 'none'
wp option update timezone_string "$WP_TIMEZONE"

# set media view for user #1
wp user meta set 1 wp_media_library_mode 'list'

# verify
wp core verify-checksums
