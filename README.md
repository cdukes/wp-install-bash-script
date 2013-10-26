WP-Install Script
======================

Create and furnish a local WP install with one command!

**Step 1**: Setup your variables at the top of the script.

**Step 2**: Open Terminal.

**Step 3**: Type `bash {your script location} {your site slug}`.

What this script does (in a nutshell):
- Creates a folder with your site slug in ~/Sites
- Sets up a DB
- Downloads, installs, and configures the latest version of WP
- Downloads some useful plugins
- Installs Genesis (link to your local copy in variables)
- Imports WP Test data
- Cleans permalinks
- Sets some basic site options
- Installs Bones for Genesis

**This is version 0.0.1. Expect to need to tweak this to your preferences, workflow, and local development setup. More robust scripting to come!**