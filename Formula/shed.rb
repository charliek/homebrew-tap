class Shed < Formula
  desc "CLI and server for managing persistent VM-based dev environments"
  homepage "https://github.com/charliek/shed"
  version "0.3.1"
  license "MIT"

  depends_on "vfkit"

  on_macos do
    on_arm do
      url "https://github.com/charliek/shed/releases/download/v0.3.1/shed_darwin_arm64.tar.gz"
      sha256 "b371b5ec98d3b10813e9c71bf3427bca98a60b8a0b4ae78f8491e005123bdc68"

      resource "shed-server" do
        url "https://github.com/charliek/shed/releases/download/v0.3.1/shed-server_darwin_arm64.tar.gz"
        sha256 "d3fee2f90408068298ae9c5e9547821466bd5108ebb146f9b47b988763ee6121"
      end
    end

    on_intel do
      url "https://github.com/charliek/shed/releases/download/v0.3.1/shed_darwin_amd64.tar.gz"
      sha256 "74fe29c1b6bbe2399b8348d347e6f204db89cbac5d47d7d342e4f060e8d68eb7"

      resource "shed-server" do
        url "https://github.com/charliek/shed/releases/download/v0.3.1/shed-server_darwin_amd64.tar.gz"
        sha256 "6f9bbb72d9b7d4a09a4b36520e947c6f7ae53a16b484b03da58b8fe6dd82317f"
      end
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/charliek/shed/releases/download/v0.3.1/shed_linux_arm64.tar.gz"
      sha256 "12365fe6792da37fa31f88dc4fb3d7e867f8299a822d296de73b82bdd84c244c"

      resource "shed-server" do
        url "https://github.com/charliek/shed/releases/download/v0.3.1/shed-server_linux_arm64.tar.gz"
        sha256 "06c4bd8a67a48dd53333c4215f48c79fc924a0933f3f895762b106f2d9ef2810"
      end
    end

    on_intel do
      url "https://github.com/charliek/shed/releases/download/v0.3.1/shed_linux_amd64.tar.gz"
      sha256 "118d664554d14e96006eaa80e1cbe28b23609f0dd93dbb5ed3235823e6b7b81d"

      resource "shed-server" do
        url "https://github.com/charliek/shed/releases/download/v0.3.1/shed-server_linux_amd64.tar.gz"
        sha256 "ad4bd2b3ab676ea02bf5601142e95ee0594565643c4cc095936021be32ee6ab7"
      end
    end
  end

  def install
    bin.install "shed"

    resource("shed-server").stage do
      bin.install "shed-server"
    end

    (etc/"shed").mkpath
    unless (etc/"shed/server.yaml").exist?
      (etc/"shed/server.yaml").write <<~YAML
        # Shed Server Configuration
        # Full reference: https://github.com/charliek/shed/blob/main/configs/server.example.yaml

        # Server identity
        name: my-server

        # Network configuration
        http_port: 8080
        ssh_port: 2222

        # Backend: vz (macOS), firecracker (Linux), or detect (auto)
        default_backend: detect

        # Logging level: debug, info, warn, error
        log_level: info

        # Credentials to mount into VMs
        # credentials:
        #   claude:
        #     source: ~/.claude
        #     target: /home/shed/.claude
        #     readonly: false

        # Environment file (KEY=value per line, injected into VMs)
        # env_file: ~/.shed/env

        # Extensions to enable in VMs
        # extensions:
        #   enabled:
        #     - ssh-agent
        #     - aws-credentials
      YAML
    end
  end

  service do
    run [opt_bin/"shed-server", "serve", "--config", etc/"shed/server.yaml"]
    keep_alive true
    log_path var/"log/shed-server.log"
    error_log_path var/"log/shed-server.log"
  end

  def caveats
    <<~EOS
      The shed-server config has been installed to:
        #{etc}/shed/server.yaml

      To start shed-server as a background service:
        brew services start shed

      Logs: #{var}/log/shed-server.log

      Note: shed-server requires Docker for VM image management.
    EOS
  end

  test do
    system bin/"shed", "version"
  end
end
