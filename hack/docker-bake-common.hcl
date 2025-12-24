# Common definitions shared between Web and Cron builds

variable "REGISTRY_CACHE_WEB" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cache"
}

variable "REGISTRY_CACHE_CRON" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cron-cache"
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

# Generic cache-from function
# usage: get-cache-from(REGISTRY_CACHE_WEB, "6.5.0")
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
