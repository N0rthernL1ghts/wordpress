# wordpress
Worpress docker image, powered by nginx/php-fpm combo and managed by s6 supervisor.

Attempt to fix several of WordPress anti-patterns in ready to deploy container

### TODO
* Out-of-the-box SSL support
* ~Disable core updates~
* Install/update plugins on the fly using wp cli (with versioning)
* Install/update themes on the fly using wp cli (with versioning)
* ~Apply theme and eventual plugin customizations using patch files~ (Partial)
* Support automatic install using ENV
* Create users automatically using ENV
