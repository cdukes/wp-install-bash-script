set -o nounset
set -o errexit

# get variables
SITENAME=$1
. "$(dirname "$0")"/wp-setup-config.sh

# create and enter folder
cd ~/Sites
mkdir $SITENAME
cd $SITENAME

# create DB
mysql -h localhost -u $DB_USER -p$DB_PW -Bse "CREATE DATABASE $SITENAME; "

# download and install WP
wp core download
wp core config --dbname=$SITENAME --dbuser=$DB_USER --dbpass=$DB_PW --extra-php <<PHP
define( 'WP_DEBUG', true );

/**
 * Manually define site location
 */
define('WP_SITEURL', 'http://$SITENAME.dev');
define('WP_HOME', 'http://$SITENAME.dev');

/**
 * Limit post revision history
 */
define('WP_POST_REVISIONS', 3);

/**
 * Skip /wp-content/ when upgrading
 */
define('CORE_UPGRADE_SKIP_NEW_BUNDLED', true );

/**
 * Increase PHP memory limit
 */
define('WP_MEMORY_LIMIT', '96M');

/**
 * Empty trash more frequently
 */
define('EMPTY_TRASH_DAYS', 15 );

/**
 * Enable trash for media items
 */
define('MEDIA_TRASH', true);

/**
 * Prevent theme/plugin file editing
 */
define('DISALLOW_FILE_EDIT', true);
PHP
wp core install --url=http://$SITENAME.dev --title=$SITENAME --admin_user=$WP_USER --admin_password=$WP_PW --admin_email=$WP_EMAIL

# install plugins
wp plugin uninstall akismet
wp plugin uninstall hello
wp plugin install "$WP_ACF_LOCATION"
wp plugin install regenerate-thumbnails
# wp plugin install theme-check
# wp plugin install developer
wp plugin install underconstruction
wp plugin install query-monitor
wp plugin install velvet-blues-update-urls
wp plugin install wordpress-seo
# wp plugin install wp-crontrol
wp plugin install wp-smushit
wp plugin install wordpress-importer

# cleanup themes
wp theme delete twentythirteen
wp theme delete twentytwelve
wp theme install "$WP_GENESIS_LOCATION"

# add test XML
wp site empty --yes
# curl -O https://raw.github.com/manovotny/wptest/master/wptest.xml
# wp import wptest.xml --authors=create
# rm wptest.xml

# clean db
wp db repair
wp db optimize
wp cache flush

# flush permalinks
wp rewrite structure '/%postname%/' --hard

# update site options
wp option update blogdescription ''
wp option update blog_public '0'
wp option update default_comment_status 'closed'
wp option update timezone_string "$WP_TIMEZONE"

# bones theme
cd wp-content/themes
git clone https://github.com/cdukes/bones-for-genesis-2-0.git genesis-$SITENAME