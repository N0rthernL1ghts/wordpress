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
    "6_5_3"
  ]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

variable "REGISTRY_CACHE" {
  default = "ghcr.io/n0rthernl1ghts/wordpress-cache"
}

######################
# Define the functions
######################

# Get the arguments for the build
function "get-args" {
  params = [version, patch_version]
  result = {
    WP_VERSION = version
    WP_PATCH_VERSION = patch_version
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

target "6_2_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.2.0")
  cache-to   = get-cache-to("6.2.0")
  tags       = get-tags("6.2.0", [])
  args       = get-args("6.2.0", "5.9.1")
}

target "6_2_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.2.1")
  cache-to   = get-cache-to("6.2.1")
  tags       = get-tags("6.2.1", [])
  args       = get-args("6.2.1", "5.9.1")
}

target "6_2_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.2.2")
  cache-to   = get-cache-to("6.2.2")
  tags       = get-tags("6.2.2", ["6.2"])
  args       = get-args("6.2.2", "5.9.1")
}

target "6_3_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.3.0")
  cache-to   = get-cache-to("6.3.0")
  tags       = get-tags("6.3.0", [])
  args       = get-args("6.3.0", "6.3.0")
}

target "6_3_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.3.1")
  cache-to   = get-cache-to("6.3.1")
  tags       = get-tags("6.3.1", [])
  args       = get-args("6.3.1", "6.3.0")
}

target "6_3_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.3.2")
  cache-to   = get-cache-to("6.3.2")
  tags       = get-tags("6.3.2", [])
  args       = get-args("6.3.2", "6.3.0")
}

target "6_4_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.0")
  cache-to   = get-cache-to("6.4.0")
  tags       = get-tags("6.4.0", [])
  args       = get-args("6.4.0", "6.4.0")
}

target "6_4_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.1")
  cache-to   = get-cache-to("6.4.1")
  tags       = get-tags("6.4.1", [])
  args       = get-args("6.4.1", "6.4.0")
}

target "6_4_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.2")
  cache-to   = get-cache-to("6.4.2")
  tags       = get-tags("6.4.2", [])
  args       = get-args("6.4.2", "6.4.0")
}

target "6_4_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.4.3")
  cache-to   = get-cache-to("6.4.3")
  tags       = get-tags("6.4.3", ["6.4"])
  args       = get-args("6.4.3", "6.4.0")
}

target "6_5_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.0")
  cache-to   = get-cache-to("6.5.0")
  tags       = get-tags("6.5.0", [])
  args       = get-args("6.5.0", "6.5.0")
}

target "6_5_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.2")
  cache-to   = get-cache-to("6.5.2")
  tags       = get-tags("6.5.2", [])
  args       = get-args("6.5.2", "6.5.0")
}

target "6_5_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.5.3")
  cache-to   = get-cache-to("6.5.3")
  tags       = get-tags("6.5.3", ["6", "6.5", "latest"])
  args       = get-args("6.5.3", "6.5.0")
}