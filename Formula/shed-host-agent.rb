class ShedHostAgent < Formula
  desc "Host-side credential brokering agent for shed VMs"
  homepage "https://github.com/charliek/shed-extensions"
  version "0.3.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/charliek/shed-extensions/releases/download/v0.3.1/shed-host-agent_darwin_arm64.tar.gz"
      sha256 "514727dedc8c12b16d972e0bd888bb2253129c8fa50ef79c1c2c1486f60403ac"
    end

    on_intel do
      url "https://github.com/charliek/shed-extensions/releases/download/v0.3.1/shed-host-agent_darwin_amd64.tar.gz"
      sha256 "05922a6d604e3ea0c48b0bac3e4816e1cd5c65440c6d9527727ccb4502f26508"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/charliek/shed-extensions/releases/download/v0.3.1/shed-host-agent_linux_arm64.tar.gz"
      sha256 "199ce349f18cda2eebda189f32ea3826f39e71293bb383bc21617b623626f1b7"
    end

    on_intel do
      url "https://github.com/charliek/shed-extensions/releases/download/v0.3.1/shed-host-agent_linux_amd64.tar.gz"
      sha256 "d0b911db2e835ee2a561d276a35e334b0b8ae11e7c1f5b5b770205ea22590dac"
    end
  end

  def install
    bin.install "shed-host-agent"

    (etc/"shed").mkpath
    unless (etc/"shed/extensions.yaml").exist?
      (etc/"shed/extensions.yaml").write <<~YAML
        # Shed Host Agent Configuration
        # Full reference: https://github.com/charliek/shed-extensions

        # Shed server URL
        server: http://localhost:8080

        # SSH agent configuration
        ssh:
          # Mode: "agent-forward" or "local-keys" (empty for auto-detect)
          mode: ""
          # Biometric approval (Touch ID on macOS)
          approval:
            enabled: false
            # Policy: "per-request", "per-session", or "per-shed"
            policy: per-session
            session_ttl: 4h

        # AWS credential vending
        aws:
          source_profile: default
          default_role: ""
          session_duration: 1h
          cache_refresh_before: 5m
          # Per-shed role overrides
          # sheds:
          #   my-shed:
          #     role: arn:aws:iam::123456789012:role/ShedRole

        # Docker registry credential proxying
        docker:
          # Allowed registry hostnames (empty = none)
          registries: []
          # Set true to allow all registries
          allow_all: false

        # Audit logging
        logging:
          enabled: true
          path: ~/.local/share/shed/extensions-audit.log
      YAML
    end
  end

  service do
    run [opt_bin/"shed-host-agent", "-config", etc/"shed/extensions.yaml"]
    keep_alive true
    log_path var/"log/shed-host-agent.log"
    error_log_path var/"log/shed-host-agent.log"
  end

  def caveats
    <<~EOS
      The shed-host-agent config has been installed to:
        #{etc}/shed/extensions.yaml

      To start shed-host-agent as a background service:
        brew services start shed-host-agent

      Logs: #{var}/log/shed-host-agent.log
    EOS
  end

  test do
    system bin/"shed-host-agent", "version"
  end
end
