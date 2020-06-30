# wordpress
Worpress docker image, powered by nginx/php-fpm combo and managed by s6 supervisor.

Attempt to fix several of WordPress anti-patterns in ready to deploy container

### TODO
* Out-of-the-box SSL support
* Disable core updates
* Install plugins on the fly using wp cli
* Install themes on the fly using wp cli
* Apply theme and eventual plugin customizations using patch files
* Support automatic install using ENV
* Create users automatically using ENV
