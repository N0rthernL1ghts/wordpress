# Patch Helper Utility
This utility is intended for developers/contributors to more painlessly create a patch(es) for core WordPress file(s).

The flow is like this:

```
$ ./00-download-file.sh
# Modify file prefixed with mod-
$ ./01-create-patch.sh
# Copy over finished patch to appropriate location in rootfs/etc/wp-mods
```
Instructions are provided by the scripts.



### Supported patches
 - **wp-admin/update-core.php**  
 Click [here](https://github.com/N0rthernL1ghts/wordpress/wiki/WordPress-Core-Updates) for details.