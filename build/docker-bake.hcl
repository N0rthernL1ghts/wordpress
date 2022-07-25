group "default" {
  targets = ["5_3_0", "5_3_1", "5_3_2", "5_4_0", "5_4_1", "5_4_2", "5_5_1", "5_5_3", "5_6_0", "5_6_1", "5_6_2", "5_7_0", "5_7_1", "5_7_2", "5_8_0", "5_8_1", "5_8_2", "5_8_3", "5_9_0", "5_9_1", "5_9_2", "5_9_3", "6.0.0", "6_0_1"]
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

target "5_3_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.3.0"]
  args = {
    WP_VERSION = "5.3.0"
  }
}

target "5_3_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.3.1"]
  args = {
    WP_VERSION = "5.3.1"
  }
}

target "5_3_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.3.2", "docker.io/nlss/wordpress:5.3"]
  args = {
    WP_VERSION = "5.3.2"
  }
}

target "5_4_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.4.0"]
  args = {
    WP_VERSION = "5.4.0"
  }
}

target "5_4_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.4.1"]
  args = {
    WP_VERSION = "5.4.1"
  }
}

target "5_4_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.4.2", "docker.io/nlss/wordpress:5.4"]
  args = {
    WP_VERSION = "5.4.2"
  }
}

target "5_5_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.5.1"]
  args = {
    WP_VERSION = "5.5.1"
  }
}

target "5_5_3" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.5.3", "docker.io/nlss/wordpress:5.5"]
  args = {
    WP_VERSION = "5.5.3"
  }
}

target "5_6_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.6.0"]
  args = {
    WP_VERSION = "5.6.0"
  }
}

target "5_6_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.6.1"]
  args = {
    WP_VERSION = "5.6.1"
  }
}

target "5_6_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.6.2", "docker.io/nlss/wordpress:5.6"]
  args = {
    WP_VERSION = "5.6.2"
  }
}

target "5_7_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.7.0"]
  args = {
    WP_VERSION = "5.7.0"
  }
}

target "5_7_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.7.1"]
  args = {
    WP_VERSION = "5.7.1"
  }
}

target "5_7_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.7.2", "docker.io/nlss/wordpress:5.7"]
  args = {
    WP_VERSION = "5.7.2"
  }
}

target "5_8_0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.0"]
  args = {
    WP_VERSION = "5.8.0"
  }
}

target "5_8_1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.1"]
  args = {
    WP_VERSION = "5.8.1"
  }
}

target "5_8_2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.2"]
  args = {
    WP_VERSION = "5.8.2"
  }
}

target "5_8_3" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.3", "docker.io/nlss/wordpress:5.8"]
  args = {
    WP_VERSION = "5.8.3"
  }
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
  tags     = ["docker.io/nlss/wordpress:5.9.3", "docker.io/nlss/wordpress:5.9"]
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
  tags     = ["docker.io/nlss/wordpress:6.0.1", "docker.io/nlss/wordpress:6.0", "docker.io/nlss/wordpress:latest"]
  args = {
    WP_VERSION = "6.0.1"
  }
}