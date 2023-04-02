group "default" {
  targets = ["5_9_0", "5_9_1", "5_9_2", "5_9_3", "6_0_0", "6_0_1", "6_0_2", "6_0_3", "6_1_0", "6_1_1", "6_2_0"]
}

target "build-dockerfile" {
  dockerfile = "Dockerfile"
}

target "build-platforms" {
  platforms = ["linux/amd64", "linux/armhf", "linux/aarch64"]
}

target "build-common" {
  pull = true
}

target "5_9_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.9.0"]
  args = {
    WP_VERSION = "5.9.0"
  }
}

target "5_9_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.9.1"]
  args = {
    WP_VERSION = "5.9.1"
  }
}

target "5_9_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.9.2"]
  args = {
    WP_VERSION = "5.9.2"
  }
}

target "5_9_3" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5", "docker.io/nlss/wordpress:5.9", "docker.io/nlss/wordpress:5.9.3"]
  args = {
    WP_VERSION = "5.9.3"
  }
}

target "6_0_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6.0.0"]
  args = {
    WP_VERSION = "6.0.0"
  }
}

target "6_0_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6.0.1"]
  args = {
    WP_VERSION = "6.0.1"
  }
}

target "6_0_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6.0.2"]
  args = {
    WP_VERSION = "6.0.2"
  }
}

target "6_0_3" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6.0.3"]
  args = {
    WP_VERSION = "6.0.3"
  }
}

target "6_1_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6.1.0"]
  args = {
    WP_VERSION = "6.1.0"
  }
}

target "6_1_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6.1", "docker.io/nlss/wordpress:6.1.1"]
  args = {
    WP_VERSION = "6.1.1"
  }
}

target "6_2_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:6", "docker.io/nlss/wordpress:6.2", "docker.io/nlss/wordpress:6.2.0", "docker.io/nlss/wordpress:latest"]
  args = {
    WP_VERSION = "6.2.0"
  }
}