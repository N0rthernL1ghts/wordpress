group "default" {
  targets = [
    "6_2_0",
    "6_2_1",
    "6_2_2",
    "6_3_0",
    "6_3_1",
    "6_3_2",
    "6_4_0",
    "6_4_1",
    "6_4_2",
    "6_4_3",
    "6_5_0",
    "6_5_2",
    "6_5_3",
    "6_5_4",
    "6_5_5",
    "6_6_0",
    "6_6_1",
    "6_6_2",
    "6_7_0",
    "6_7_1",
    "6_7_2",
    "6_8_0"
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile.cron"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cron-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [version]
  result = {
    WP_VERSION = version
  }
}

# Get the cache-from configuration
function "get-cache-from" {
  params = [version]
  result = [
    "type=registry,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get the cache-to configuration
function "get-cache-to" {
  params = [version]
  result = [
    "type=registry,mode=max,ref=${REGISTRY_CACHE}:${sha1("${version}-${BAKE_LOCAL_PLATFORM}")}"
  ]
}

# Get list of image tags and registries
# Takes a version and a list of extra versions to tag
# eg. get-tags("6.2.0", ["6", "6.2", "latest"])
function "get-tags" {
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

target "6_2_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.2.0")
  cache-to   = get-cache-to("6.2.0")
  tags       = get-tags("6.2.0", [])
  args       = get-args("6.2.0")
}

target "6_2_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.2.1")
  cache-to   = get-cache-to("6.2.1")
  tags       = get-tags("6.2.1", [])
  args       = get-args("6.2.1")
}

target "6_2_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.2.2")
  cache-to   = get-cache-to("6.2.2")
  tags       = get-tags("6.2.2", ["6.2"])
  args       = get-args("6.2.2")
}

target "6_3_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.3.0")
  cache-to   = get-cache-to("6.3.0")
  tags       = get-tags("6.3.0", [])
  args       = get-args("6.3.0")
}

target "6_3_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.3.1")
  cache-to   = get-cache-to("6.3.1")
  tags       = get-tags("6.3.1", [])
  args       = get-args("6.3.1")
}

target "6_3_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.3.2")
  cache-to   = get-cache-to("6.3.2")
  tags       = get-tags("6.3.2", [])
  args       = get-args("6.3.2")
}

target "6_4_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.0")
  cache-to   = get-cache-to("6.4.0")
  tags       = get-tags("6.4.0", [])
  args       = get-args("6.4.0")
}

target "6_4_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.1")
  cache-to   = get-cache-to("6.4.1")
  tags       = get-tags("6.4.1", [])
  args       = get-args("6.4.1")
}

target "6_4_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.2")
  cache-to   = get-cache-to("6.4.2")
  tags       = get-tags("6.4.2", [])
  args       = get-args("6.4.2")
}

target "6_4_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.3")
  cache-to   = get-cache-to("6.4.3")
  tags       = get-tags("6.4.3", ["6.4"])
  args       = get-args("6.4.3")
}

target "6_5_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.0")
  cache-to   = get-cache-to("6.5.0")
  tags       = get-tags("6.5.0", [])
  args       = get-args("6.5.0")
}

target "6_5_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.2")
  cache-to   = get-cache-to("6.5.2")
  tags       = get-tags("6.5.2", [])
  args       = get-args("6.5.2")
}

target "6_5_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.3")
  cache-to   = get-cache-to("6.5.3")
  tags       = get-tags("6.5.3", [])
  args       = get-args("6.5.3")
}

target "6_5_4" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.4")
  cache-to   = get-cache-to("6.5.4")
  tags       = get-tags("6.5.4", [])
  args       = get-args("6.5.4")
}

target "6_5_5" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.5")
  cache-to   = get-cache-to("6.5.5")
  tags       = get-tags("6.5.5", ["6.5"])
  args       = get-args("6.5.5")
}

target "6_6_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.6.0")
  cache-to   = get-cache-to("6.6.0")
  tags       = get-tags("6.6.0", [])
  args       = get-args("6.6.0")
}

target "6_6_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.6.1")
  cache-to   = get-cache-to("6.6.1")
  tags       = get-tags("6.6.1", [])
  args       = get-args("6.6.1")
}

target "6_6_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.6.2")
  cache-to   = get-cache-to("6.6.2")
  tags       = get-tags("6.6.2", ["6.6"])
  args       = get-args("6.6.2")
}

target "6_7_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.7.0")
  cache-to   = get-cache-to("6.7.0")
  tags       = get-tags("6.7.0", [])
  args       = get-args("6.7.0")
}

target "6_7_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.7.1")
  cache-to   = get-cache-to("6.7.1")
  tags       = get-tags("6.7.1", [])
  args       = get-args("6.7.1")
}

target "6_7_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.7.2")
  cache-to   = get-cache-to("6.7.2")
  tags       = get-tags("6.7.2", ["6.7"])
  args       = get-args("6.7.2")
}

target "6_8_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.8.0")
  cache-to   = get-cache-to("6.8.0")
  tags       = get-tags("6.8.0", ["6", "6.8", "latest"])
  args       = get-args("6.8.0")
}