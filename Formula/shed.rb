class Shed < Formula
  desc "CLI and server for managing persistent VM-based dev environments"
  homepage "https://github.com/charliek/shed"
  version "0.3.1"
  license "MIT"

  on_macos do
    depends_on "vfkit"
  end

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
    write_default_config unless (etc/"shed/server.yaml").exist?
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

      Edit the config to enable credential mounts and extensions,
      then start shed-server as a background service:
        brew services start shed

      Logs: #{var}/log/shed-server.log

      Note: shed-server requires Docker for VM image management.
    EOS
  end

  test do
    system bin/"shed", "version"
  end

  private

  def write_default_config
    if OS.mac?
      write_macos_config
    else
      write_linux_config
    end
  end

  def write_macos_config
    (etc/"shed/server.yaml").write <<~YAML
      # Shed Server Configuration
      # Full reference: https://github.com/charliek/shed/blob/main/configs/server.example.yaml

      name: my-server

      http_port: 8080
      ssh_port: 2222

      default_backend: vz
      log_level: info

      # Credentials to mount into VMs
      # Using ~/.shed/mounts/ keeps host and VM configs separate.
      # credentials:
      #   claude:
      #     source: ~/.shed/mounts/claude
      #     target: /home/shed/.claude
      #     readonly: false
      #   codex:
      #     source: ~/.shed/mounts/codex
      #     target: /home/shed/.codex
      #     readonly: false
      #   opencode_data:
      #     source: ~/.shed/mounts/opencode/share
      #     target: /home/shed/.local/share/opencode
      #     readonly: false
      #   opencode_state:
      #     source: ~/.shed/mounts/opencode/state
      #     target: /home/shed/.local/state/opencode
      #     readonly: false
      #   gh:
      #     source: ~/.shed/mounts/gh
      #     target: /home/shed/.config/gh
      #     readonly: false

      # Environment file (KEY=value per line, injected into VMs)
      # env_file: ~/.shed/env

      # Extensions to enable in VMs (requires shed-host-agent)
      # extensions:
      #   enabled:
      #     - ssh-agent
      #     - aws-credentials
      #     - docker-credentials

      vz:
        vfkit_path: vfkit
        kernel_path: ~/Library/Application Support/shed/vz/vmlinux
        initrd_path: ~/Library/Application Support/shed/vz/initrd.img
        base_rootfs: ghcr.io/charliek/shed-vz-experimental:v#{version}
        images:
          base: ghcr.io/charliek/shed-vz-base:v#{version}
          experimental: ghcr.io/charliek/shed-vz-experimental:v#{version}
        instance_dir: ~/Library/Application Support/shed/vz/instances
        socket_dir: ~/.shed/vz/sockets
        default_cpus: 2
        default_memory_mb: 4096
        default_disk_gb: 20
        start_timeout: 60s
        stop_timeout: 10s
    YAML
  end

  def write_linux_config
    (etc/"shed/server.yaml").write <<~YAML
      # Shed Server Configuration
      # Full reference: https://github.com/charliek/shed/blob/main/configs/server.example.yaml

      name: my-server

      http_port: 8080
      ssh_port: 2222

      default_backend: firecracker
      log_level: info

      # Credentials to mount into VMs
      # Using ~/.shed/mounts/ keeps host and VM configs separate.
      # credentials:
      #   claude:
      #     source: ~/.shed/mounts/claude
      #     target: /home/shed/.claude
      #     readonly: false
      #   codex:
      #     source: ~/.shed/mounts/codex
      #     target: /home/shed/.codex
      #     readonly: false
      #   gh:
      #     source: ~/.shed/mounts/gh
      #     target: /home/shed/.config/gh
      #     readonly: false

      # Environment file (KEY=value per line, injected into VMs)
      # env_file: ~/.shed/env

      # Extensions to enable in VMs (requires shed-host-agent)
      # extensions:
      #   enabled:
      #     - ssh-agent
      #     - aws-credentials
      #     - docker-credentials

      firecracker:
        kernel_path: /var/lib/shed/firecracker/images/vmlinux
        base_rootfs: ghcr.io/charliek/shed-fc-base:v#{version}
        images:
          base: ghcr.io/charliek/shed-fc-base:v#{version}
        instance_dir: /var/lib/shed/firecracker/instances
        socket_dir: /var/run/shed/firecracker
        default_cpus: 2
        default_memory_mb: 4096
        default_disk_gb: 20
        vsock_base_cid: 100
        start_timeout: 90s
        stop_timeout: 10s
        bridge_name: shed-br0
        bridge_cidr: 172.30.0.1/24
        tap_prefix: shed-tap
    YAML
  end
end
