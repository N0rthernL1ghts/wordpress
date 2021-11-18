group "default" {
  targets = ["5.3.0", "5.3.1", "5.3.2", "5.4.0", "5.4.1", "5.4.2", "5.5.1", "5.5.3", "5.6.0", "5.6.1", "5.6.2", "5.7.0", "5.7.1", "5.7.2", "5.8.0", "5.8.1", "5.8.2"]
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

target "5.3.0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.3.0"]
  args = {
    WP_VERSION = "5.3.0"
  }
}

target "5.3.1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.3.1"]
  args = {
    WP_VERSION = "5.3.1"
  }
}

target "5.3.2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.3.2"]
  args = {
    WP_VERSION = "5.3.2"
  }
}

target "5.4.0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.4.0"]
  args = {
    WP_VERSION = "5.4.0"
  }
}

target "5.4.1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.4.1"]
  args = {
    WP_VERSION = "5.4.1"
  }
}

target "5.4.2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.4.2"]
  args = {
    WP_VERSION = "5.4.2"
  }
}

target "5.5.1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.5.1"]
  args = {
    WP_VERSION = "5.5.1"
  }
}

target "5.5.3" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.5.3"]
  args = {
    WP_VERSION = "5.5.3"
  }
}

target "5.6.0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.6.0"]
  args = {
    WP_VERSION = "5.6.0"
  }
}

target "5.6.1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.6.1"]
  args = {
    WP_VERSION = "5.6.1"
  }
}

target "5.6.2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.6.2"]
  args = {
    WP_VERSION = "5.6.2"
  }
}

target "5.7.0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.7.0"]
  args = {
    WP_VERSION = "5.7.0"
  }
}

target "5.7.1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.7.1"]
  args = {
    WP_VERSION = "5.7.1"
  }
}

target "5.7.2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.7.2"]
  args = {
    WP_VERSION = "5.7.2"
  }
}

target "5.8.0" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.0"]
  args = {
    WP_VERSION = "5.8.0"
  }
}

target "5.8.1" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.1", "docker.io/nlss/wordpress:latest"]
  args = {
    WP_VERSION = "5.8.1"
  }
}

target "5.8.2" {
  inherits = ["build-dockerfile", "build-platforms", "build-common"]
  tags     = ["docker.io/nlss/wordpress:5.8.2", "docker.io/nlss/wordpress:latest"]
  args = {
    WP_VERSION = "5.8.2"
  }
}
