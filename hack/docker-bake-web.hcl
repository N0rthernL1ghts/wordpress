group "default" {
  targets = ["web", "cron"]
}

target "web" {
  name = "web_${replace(version, ".", "_")}"
  matrix = {
    version = keys(WP_VERSIONS)
  }
  inherits = ["build-dockerfile", "build-platforms"]
  target = "wordpress-base"
  
  args = {
    WP_VERSION = version
    WP_PATCH_VERSION = WP_VERSIONS[version].patch_version
  }
  
  tags = get-tags("ghcr.io/n0rthernl1ghts/wordpress", version, WP_VERSIONS[version].extra_tags)
  
  cache-from = get-cache-from(REGISTRY_CACHE_WEB, version)
  cache-to   = get-cache-to(REGISTRY_CACHE_WEB, version)
}