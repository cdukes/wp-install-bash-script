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
mysql -h localhost -u $DB_USER -p$DB_PW -Bse "CREATE DATABASE $SITENAME; "

# download and install WP
wp core download
wp core config --dbname=$SITENAME --dbuser=$DB_USER --dbpass=$DB_PW --extra-php <<PHP
if( !(defined( 'DOING_AJAX' ) && DOING_AJAX) ) {
	define( 'WP_DEBUG', true );
	define( 'WP_DEBUG_LOG', false );
	define( 'SCRIPT_DEBUG', true );
}

/**
 * Don't combine admin scripts
 */
define( 'CONCATENATE_SCRIPTS', false );

/**
 * Manually define site location
 */
define( 'WP_SITEURL', 'https://$SITENAME.t.test' );
define( 'WP_HOME', 'https://$SITENAME.t.test' );

/**
 * Limit post revision history
 */
define( 'WP_POST_REVISIONS', 3 );

/**
 * Skip /wp-content/ when upgrading
 */
define( 'CORE_UPGRADE_SKIP_NEW_BUNDLED', true );
define( 'WP_AUTO_UPDATE_CORE', 'minor' );

/**
 * Increase PHP memory limit
 */
define( 'WP_MEMORY_LIMIT', '96M' );
define( 'WP_MAX_MEMORY_LIMIT', '128M' );

/**
 * Empty trash more frequently
 */
define( 'EMPTY_TRASH_DAYS', 15 );

/**
 * Enable trash for media items
 */
// define( 'MEDIA_TRASH', true );

/**
 * Prevent theme/plugin file editing
 */
define( 'DISALLOW_FILE_EDIT', true );
// define( 'DISALLOW_FILE_MODS', true );

/**
 * Set default theme
 */
define( 'WP_DEFAULT_THEME', 'genesis' );

/**
 * Set post autosave interval
 */
define( 'AUTOSAVE_INTERVAL', 60 );
PHP
wp core install --url=https://$SITENAME.t.test --title=$SITENAME --admin_user=$WP_USER --admin_password=$WP_PW --admin_email=$WP_EMAIL --skip-email

# install plugins
wp plugin uninstall akismet
wp plugin uninstall hello
wp plugin install "$WP_ACF_LOCATION" --activate
wp plugin install capability-manager-enhanced
wp plugin install block-options
wp plugin install classic-editor
wp plugin install disable-blog
wp plugin install disable-comments --activate
wp plugin install disable-embeds --activate
wp plugin install disable-emojis --activate
wp plugin install disable-json-api --activate
wp plugin install ewww-image-optimizer
wp plugin install forbid-pwned-passwords --activate
wp plugin install image-processing-queue --activate
wp plugin install imsanity --activate
wp plugin install limit-login-attempts-reloaded --activate
wp plugin install png-to-jpg --activate
wp plugin install query-monitor
wp plugin install redirection
wp plugin install regenerate-thumbnails
wp plugin install rewrite-rules-inspector
wp plugin install underconstruction
wp plugin install velvet-blues-update-urls
wp plugin install wordpress-importer
wp plugin install wordpress-seo --activate
wp plugin install wp-crontrol

# MU plugins
wp plugin install password-bcrypt
wp eval 'mkdir(WP_CONTENT_DIR . "/mu-plugins/");'
wp eval 'rename(WP_CONTENT_DIR . "/plugins/password-bcrypt/wp-password-bcrypt.php", WP_CONTENT_DIR . "/mu-plugins/wp-password-bcrypt.php");'
rm -rf wp-content/plugins/password-bcrypt

# cleanup themes
wp theme delete twentynineteen
wp theme delete twentyseventeen
wp theme delete twentysixteen
wp theme delete twentyfifteen

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
# wp rewrite structure '/%postname%/' --hard

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

# bones theme
while [[ $# -gt 0 ]]; do
	case "$1" in
	--install-bones|-B)
		cd wp-content/themes
		git clone https://github.com/cdukes/bones-for-genesis-2-0.git genesis-$SITENAME
		cd genesis-$SITENAME
		npm update --save-dev
		bower update --save
		wp theme install "$WP_GENESIS_LOCATION"
		wp theme activate genesis-$SITENAME
		shift
		;;
	*)
		echo "Invalid option: $1"
		# exit 1
		;;
	esac
	shift
done
