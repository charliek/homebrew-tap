class Prox < Formula
  desc "Modern process manager for development with API-first design"
  homepage "https://github.com/charliek/prox"
  version "0.0.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/charliek/prox/releases/download/v0.0.3/prox_darwin_arm64.tar.gz"
      sha256 "827e9f50d7080c00f29e03eaa015718f2d280ef98844eed2a0b91d6cf281a5ef"
    end

    on_intel do
      url "https://github.com/charliek/prox/releases/download/v0.0.3/prox_darwin_amd64.tar.gz"
      sha256 "fc3451452c66d482253b62f91009f90e0818cd52d5204fab4f4aa119cfb56518"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/charliek/prox/releases/download/v0.0.3/prox_linux_arm64.tar.gz"
      sha256 "882dfe8f635d0d662556dd207cddf85e4359eb97d3b2cf43e91ed966b4799cbe"
    end

    on_intel do
      url "https://github.com/charliek/prox/releases/download/v0.0.3/prox_linux_amd64.tar.gz"
      sha256 "eb9d07658f3a0c226d4c6c001151fcc12a1fc445cd0b850eb51301f447bb3eda"
    end
  end

  def install
    bin.install "prox"
  end

  test do
    system bin/"prox", "version"
  end
end
