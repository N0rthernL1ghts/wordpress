group "default" {
  targets = [
    "5_9_0",
    "5_9_1",
    "5_9_2",
    "5_9_3",
    "6_0_0",
    "6_0_1",
    "6_0_2",
    "6_0_3",
    "6_1_0",
    "6_1_1",
    "6_2_0",
    "6_2_1",
    "6_2_2",
    "6_3_0"
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
  default = "docker.io/nlss/wordpress-cache"
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
# eg. get-tags("5.9.0", ["5", "5.9", "latest"])
function "get-tags" {
  params = [version, extra_versions]
  result = concat(
    [
      "docker.io/nlss/wordpress:${version}",
      "ghcr.io/n0rthernl1ghts/wordpress:${version}"
    ],
    flatten([
      for extra_version in extra_versions : [
        "docker.io/nlss/wordpress:${extra_version}",
        "ghcr.io/n0rthernl1ghts/wordpress:${extra_version}"
      ]
    ])
  )
}

##########################
# Define the build targets
##########################

target "5_9_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("5.9.0")
  cache-to   = get-cache-to("5.9.0")
  tags       = get-tags("5.9.0", [])
  args       = get-args("5.9.0", "5.9.0")
}

target "5_9_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("5.9.1")
  cache-to   = get-cache-to("5.9.1")
  tags       = get-tags("5.9.1", [])
  args       = get-args("5.9.1", "5.9.1")
}

target "5_9_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("5.9.2")
  cache-to   = get-cache-to("5.9.2")
  tags       = get-tags("5.9.2", [])
  args       = get-args("5.9.2", "5.9.1")
}

target "5_9_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("5.9.3")
  cache-to   = get-cache-to("5.9.3")
  tags       = get-tags("5.9.3", ["5", "5.9"])
  args       = get-args("5.9.3", "5.9.1")
}

target "6_0_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.0.0")
  cache-to   = get-cache-to("6.0.0")
  tags       = get-tags("6.0.0", [])
  args       = get-args("6.0.0", "5.9.1")
}

target "6_0_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.0.1")
  cache-to   = get-cache-to("6.0.1")
  tags       = get-tags("6.0.1", [])
  args       = get-args("6.0.1", "5.9.1")
}

target "6_0_2" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.0.2")
  cache-to   = get-cache-to("6.0.2")
  tags       = get-tags("6.0.2", [])
  args       = get-args("6.0.2", "5.9.1")
}

target "6_0_3" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.0.3")
  cache-to   = get-cache-to("6.0.3")
  tags       = get-tags("6.0.3", ["6.0"])
  args       = get-args("6.0.3", "5.9.1")
}

target "6_1_0" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.1.0")
  cache-to   = get-cache-to("6.1.0")
  tags       = get-tags("6.1.0", [])
  args       = get-args("6.1.0", "5.9.1")
}

target "6_1_1" {
  inherits   = ["build-dockerfile", "build-platforms", "build-common"]
  cache-from = get-cache-from("6.1.1")
  cache-to   = get-cache-to("6.1.1")
  tags       = get-tags("6.1.1", ["6.1"])
  args       = get-args("6.1.1", "5.9.1")
}

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
  tags       = get-tags("6.3.0", ["6", "6.3", "latest"])
  args       = get-args("6.3.0", "6.3.0")
}
