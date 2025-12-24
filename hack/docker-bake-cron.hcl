group "cron" {
  targets = [
    "cron_6_5_0",
    "cron_6_5_2",
    "cron_6_5_3",
    "cron_6_5_4",
    "cron_6_5_5",
    "cron_6_6_0",
    "cron_6_6_1",
    "cron_6_6_2",
    "cron_6_7_0",
    "cron_6_7_1",
    "cron_6_7_2",
    "cron_6_8_0",
    "cron_6_8_1",
    "cron_6_8_2"
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull   = true
  target = "wordpress-cron"
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cron-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-cron-args" {
  params = [version]
  result = {
    WP_VERSION = version
  }
}

# Get the cache-from configuration
function "get-cron-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}",
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("main-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cron-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}",
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("main-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-cron-tags("6.2.0", ["6", "6.2", "latest"])
function "get-cron-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "ghcr.io/n0rthernl1ghts/wordpress-cron:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "ghcr.io/n0rthernl1ghts/wordpress-cron:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "cron_6_5_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.5.0")
  cache-to   = get-cron-cache-to("6.5.0")
  tags       = get-cron-tags("6.5.0", [])
  args       = get-cron-args("6.5.0")
}

target "cron_6_5_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.5.2")
  cache-to   = get-cron-cache-to("6.5.2")
  tags       = get-cron-tags("6.5.2", [])
  args       = get-cron-args("6.5.2")
}

target "cron_6_5_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.5.3")
  cache-to   = get-cron-cache-to("6.5.3")
  tags       = get-cron-tags("6.5.3", [])
  args       = get-cron-args("6.5.3")
}

target "cron_6_5_4" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.5.4")
  cache-to   = get-cron-cache-to("6.5.4")
  tags       = get-cron-tags("6.5.4", [])
  args       = get-cron-args("6.5.4")
}

target "cron_6_5_5" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.5.5")
  cache-to   = get-cron-cache-to("6.5.5")
  tags       = get-cron-tags("6.5.5", ["6.5"])
  args       = get-cron-args("6.5.5")
}

target "cron_6_6_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.6.0")
  cache-to   = get-cron-cache-to("6.6.0")
  tags       = get-cron-tags("6.6.0", [])
  args       = get-cron-args("6.6.0")
}

target "cron_6_6_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.6.1")
  cache-to   = get-cron-cache-to("6.6.1")
  tags       = get-cron-tags("6.6.1", [])
  args       = get-cron-args("6.6.1")
}

target "cron_6_6_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.6.2")
  cache-to   = get-cron-cache-to("6.6.2")
  tags       = get-cron-tags("6.6.2", ["6.6"])
  args       = get-cron-args("6.6.2")
}

target "cron_6_7_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.7.0")
  cache-to   = get-cron-cache-to("6.7.0")
  tags       = get-cron-tags("6.7.0", [])
  args       = get-cron-args("6.7.0")
}

target "cron_6_7_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.7.1")
  cache-to   = get-cron-cache-to("6.7.1")
  tags       = get-cron-tags("6.7.1", [])
  args       = get-cron-args("6.7.1")
}

target "cron_6_7_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.7.2")
  cache-to   = get-cron-cache-to("6.7.2")
  tags       = get-cron-tags("6.7.2", ["6.7"])
  args       = get-cron-args("6.7.2")
}

target "cron_6_8_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.8.0")
  cache-to   = get-cron-cache-to("6.8.0")
  tags       = get-cron-tags("6.8.0", [])
  args       = get-cron-args("6.8.0")
}

target "cron_6_8_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.8.1")
  cache-to   = get-cron-cache-to("6.8.1")
  tags       = get-cron-tags("6.8.1", [])
  args       = get-cron-args("6.8.1")
}

target "cron_6_8_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cron-cache-from("6.8.2")
  cache-to   = get-cron-cache-to("6.8.2")
  tags       = get-cron-tags("6.8.2", ["6", "6.8", "latest"])
  args       = get-cron-args("6.8.2")
}
