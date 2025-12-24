target "cron" {
  name = "cron_${replace(version, ".", "_")}"
  matrix = {
    version = keys(WP_VERSIONS)
  }
  inherits = ["build-dockerfile", "build-platforms"]
  target = "wordpress-cron"
  pull = true
  
  args = {
    WP_VERSION = version
    WP_PATCH_VERSION = WP_VERSIONS[version].patch_version
  }
  
  tags = get-tags("ghcr.io/n0rthernl1ghts/wordpress-cron", version, WP_VERSIONS[version].extra_tags)
  
  cache-from = get-cache-from(REGISTRY_CACHE_CRON, version)
  cache-to   = get-cache-to(REGISTRY_CACHE_CRON, version)
}
