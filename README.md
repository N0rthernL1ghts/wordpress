# wordpress
WorPress docker image, powered by nginx/php-fpm combo and managed by s6 supervisor.

Attempt to fix several of WordPress anti-patterns in ready to deploy container

#### Installation

You can use public build:
```
nlss/wordpress:VERSION_NUMBER

```
Replace version number with desired version, eg. 5.8.2.

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
