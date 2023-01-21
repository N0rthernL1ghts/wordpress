# wordpress
WorPress docker image, powered by nginx/php-fpm combo and managed by s6 supervisor.

Attempt to fix several of WordPress anti-patterns in ready to deploy container

#### Deprecation notice
- 2023-01-20 Deprecation of WordPress versions prior to 5.9
  * Preparation for PHP8.1 upgrade. 
  * WordPress versions prior to 5.9 have no PHP8.1 support.
  * PHP8.0 active support has ended since 2022-11-28, therefore skipping this release
  * PHP7.4 reached end-of-life on 2022-11-28 and should not be used.
  * Old images will remain, but will receive no further updates, until their eventual removal. Usage is not recommended.
  * This decision will make build stack significantly lighter, ensuring much faster future builds
- 2023-01-21 Retirement of PHP7.4. The king is dead, long live the king!

#### Public builds (docker)

You can use public build:
```
nlss/wordpress
```

You can also use specific version of WordPress:
```
nlss/wordpress:6.1.0
```

Replace version number with desired version, eg. 6.0.2.

### Automatic plugin installer
```
WARNING: This feature is experimental and can fail. Proceed with caution
```

This container can install plugins during container startup defined in environment variable WORDPRESS_PLUGIN_LIST

If environment variable is left empty, or undefined, installer will skip.

Plugins are not activated automatically; This is intentional.  

Usage example:
```
# Notice that specific version can be defined
WORDPRESS_PLUGIN_LIST=akismet:4.1.8 two-factor
```
Caveats:
* If plugin was previously installed, and not defined on the list, it will NOT be removed.
* If plugin install fails, container will exit with error

### TODO
* Out-of-the-box SSL support
* ~Disable core updates~
* ~Install/update plugins on the fly using wp cli (with versioning)~
* Install/update themes on the fly using wp cli (with versioning)
* ~Apply theme and eventual plugin customizations using patch files~ (Partial)
* Support automatic install using ENV
* Create users automatically using ENV
