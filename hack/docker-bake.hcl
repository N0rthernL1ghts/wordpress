group "default" {
  targets = ["web", "cron"]
}

group "web" {
  targets = [
    "web_6_5_0",
    "web_6_5_2",
    "web_6_5_3",
    "web_6_5_4",
    "web_6_5_5",
    "web_6_6_0",
    "web_6_6_1",
    "web_6_6_2",
    "web_6_7_0",
    "web_6_7_1",
    "web_6_7_2",
    "web_6_8_0",
    "web_6_8_1",
    "web_6_8_2"
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  target = "wordpress-base"
}


variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-web-args" {
  params = [version, patch_version]
  result = {
    WP_VERSION = version
    WP_PATCH_VERSION = patch_version
  }
}

# Get the cache-from configuration
function "get-web-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}",
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("main-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-web-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}",
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("main-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-web-tags("6.2.0", ["6", "6.2", "latest"])
function "get-web-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "ghcr.io/n0rthernl1ghts/wordpress:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "ghcr.io/n0rthernl1ghts/wordpress:${extra_version}"
      ]
    ])
  )
}


##########################
# Define the build targets
##########################

target "web_6_5_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.5.0")
  cache-to   = get-web-cache-to("6.5.0")
  tags       = get-web-tags("6.5.0", [])
  args       = get-web-args("6.5.0", "6.5.0")
}

target "web_6_5_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.5.2")
  cache-to   = get-web-cache-to("6.5.2")
  tags       = get-web-tags("6.5.2", [])
  args       = get-web-args("6.5.2", "6.5.0")
}

target "web_6_5_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.5.3")
  cache-to   = get-web-cache-to("6.5.3")
  tags       = get-web-tags("6.5.3", [])
  args       = get-web-args("6.5.3", "6.5.0")
}

target "web_6_5_4" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.5.4")
  cache-to   = get-web-cache-to("6.5.4")
  tags       = get-web-tags("6.5.4", [])
  args       = get-web-args("6.5.4", "6.5.0")
}

target "web_6_5_5" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.5.5")
  cache-to   = get-web-cache-to("6.5.5")
  tags       = get-web-tags("6.5.5", ["6.5"])
  args       = get-web-args("6.5.5", "6.5.0")
}

target "web_6_6_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.6.0")
  cache-to   = get-web-cache-to("6.6.0")
  tags       = get-web-tags("6.6.0", [])
  args       = get-web-args("6.6.0", "6.5.0")
}

target "web_6_6_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.6.1")
  cache-to   = get-web-cache-to("6.6.1")
  tags       = get-web-tags("6.6.1", [])
  args       = get-web-args("6.6.1", "6.5.0")
}

target "web_6_6_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.6.2")
  cache-to   = get-web-cache-to("6.6.2")
  tags       = get-web-tags("6.6.2", ["6.6"])
  args       = get-web-args("6.6.2", "6.5.0")
}

target "web_6_7_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.7.0")
  cache-to   = get-web-cache-to("6.7.0")
  tags       = get-web-tags("6.7.0", [])
  args       = get-web-args("6.7.0", "6.5.0")
}

target "web_6_7_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.7.1")
  cache-to   = get-web-cache-to("6.7.1")
  tags       = get-web-tags("6.7.1", [])
  args       = get-web-args("6.7.1", "6.5.0")
}

target "web_6_7_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.7.2")
  cache-to   = get-web-cache-to("6.7.2")
  tags       = get-web-tags("6.7.2", ["6.7"])
  args       = get-web-args("6.7.2", "6.5.0")
}

target "web_6_8_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.8.0")
  cache-to   = get-web-cache-to("6.8.0")
  tags       = get-web-tags("6.8.0", [])
  args       = get-web-args("6.8.0", "6.5.0")
}

target "web_6_8_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.8.1")
  cache-to   = get-web-cache-to("6.8.1")
  tags       = get-web-tags("6.8.1", [])
  args       = get-web-args("6.8.1", "6.5.0")
}

target "web_6_8_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-web-cache-from("6.8.2")
  cache-to   = get-web-cache-to("6.8.2")
  tags       = get-web-tags("6.8.2", ["6", "6.8", "latest"])
  args       = get-web-args("6.8.2", "6.5.0")
}