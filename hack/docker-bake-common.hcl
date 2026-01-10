# Common definitions shared between Web and Cron builds

variable "REGISTRY_CACHE_WEB" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cache"
}

variable "REGISTRY_CACHE_CRON" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cron-cache"
}

variable "WP_VERSIONS" {
  default = {
    "6.5.0" = { patch_version = "6.5.0", extra_tags = [] }
    "6.5.2" = { patch_version = "6.5.0", extra_tags = [] }
    "6.5.3" = { patch_version = "6.5.0", extra_tags = [] }
    "6.5.4" = { patch_version = "6.5.0", extra_tags = [] }
    "6.5.5" = { patch_version = "6.5.0", extra_tags = ["6.5"] }
    "6.6.0" = { patch_version = "6.5.0", extra_tags = [] }
    "6.6.1" = { patch_version = "6.5.0", extra_tags = [] }
    "6.6.2" = { patch_version = "6.5.0", extra_tags = ["6.6"] }
    "6.7.0" = { patch_version = "6.5.0", extra_tags = [] }
    "6.7.1" = { patch_version = "6.5.0", extra_tags = [] }
    "6.7.2" = { patch_version = "6.5.0", extra_tags = ["6.7"] }
    "6.8.0" = { patch_version = "6.5.0", extra_tags = [] }
    "6.8.1" = { patch_version = "6.5.0", extra_tags = [] }
    "6.8.2" = { patch_version = "6.5.0", extra_tags = [] }
    "6.8.3" = { patch_version = "6.5.0", extra_tags = ["6.8"] }
    "6.9.0" = { patch_version = "6.5.0", extra_tags = ["6", "6.9", "latest"] }
  }
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

# Generic cache-from function
function "get-cache-from" {
  params = [registry, version]
  result = [
    "type=registry,ref=${registry}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}",
    "type=registry,ref=${registry}:${sha1("main-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Generic cache-to function
function "get-cache-to" {
  params = [registry, version]
  result = [
    "type=registry,mode=max,ref=${registry}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}",
    "type=registry,mode=max,ref=${registry}:${sha1("main-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Generic tags generation function
function "get-tags" {
  params = [image_name, version, extra_tags]
  result = concat(
    [ "${image_name}:${version}" ],
    flatten([
      for tag in extra_tags : [ "${image_name}:${tag}" ]
    ])
  )
}