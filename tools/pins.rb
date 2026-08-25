#!/usr/bin/env ruby
# frozen_string_literal: true

# pins.rb — read versions.yaml (the repo's pin SSOT) and emit KEY=VALUE
# lines for $GITHUB_ENV.
#
#   ruby tools/pins.rb <triplet> <tool-platform> [--env]
#   ruby tools/pins.rb --release
#
# Press mode:
#   <triplet>        the feedstock triplet (aarch64-macos,
#                    x86_64-linux-gnu, x86_64-windows-ucrt) — selects the
#                    payload slice assets
#   <tool-platform>  the tebako toolchain/runtime asset platform
#                    (macos-arm64, linux-gnu-x86_64, windows-ucrt64) —
#                    selects the tebako-pkg/tebako-bootstrap/tfs assets
#
# Release mode (--release): emits the flat keys the release notes need
# (versions + release tags), no per-platform selection.
#
# With --env the output is KEY=VALUE lines (append to $GITHUB_ENV);
# without it the pairs print as shell export lines. Unknown triplet /
# missing pin is a named error, never a guess (spec 00 §9).

require "yaml"

def die(msg)
  warn "pins.rb: #{msg}"
  exit 64
end

root = File.expand_path("..", __dir__)
doc = YAML.load_file(File.join(root, "versions.yaml"))
die "versions.yaml: schema_version missing (pre-era document?)" unless doc["schema_version"] == 1

tebako = doc.fetch("tebako")
runtime = doc.fetch("runtime")
package = doc.fetch("package")
payloads = doc.fetch("payloads")

by_name = payloads.to_h { |p| [p["name"], p] }

if ARGV.include?("--release")
  notes = {
    "PKG_VERSION" => package.fetch("version"),
    "TEBAKO_VERSION" => tebako.fetch("version"),
    "RUNTIME_RUBY_NOTE" => runtime.fetch("ruby"),
    "RUNTIME_TEBAKO_NOTE" => runtime.fetch("tebako"),
    "MN_RELEASE_NOTE" => by_name.fetch("metanorma").fetch("release"),
    "JDK_RELEASE_NOTE" => by_name.fetch("openjdk").fetch("release"),
    "INK_RELEASE_NOTE" => by_name.fetch("inkscape").fetch("release"),
  }
  notes.each { |k, v| puts "#{k}=#{v}" }
  exit 0
end

triplet = ARGV[0] or die "usage: pins.rb <triplet> <tool-platform> [--env] | pins.rb --release"
tool = ARGV[1] or die "usage: pins.rb <triplet> <tool-platform> [--env] | pins.rb --release"

tool_sha = lambda do |name|
  tebako.dig("sha256", name, tool) or
    die "versions.yaml: no tebako.sha256.#{name}.#{tool} pin"
end

slice = lambda do |name|
  p = by_name[name] or die "versions.yaml: no payloads[] entry named #{name}"
  a = p.dig("assets", triplet) or
    die "versions.yaml: payload #{name} has no asset for triplet #{triplet}"
  [p, a]
end

mn_p, mn = slice.call("metanorma")
jdk_p, jdk = slice.call("openjdk")
ink_p, ink = slice.call("inkscape")

windows = tool.start_with?("windows")
# The runtime root's DECLARED spelling (spec 17 §1): /__tfs__ on POSIX,
# /t on windows (the driver re-qualifies onto the VFS drive, A:/t).
runtime_root = windows ? "/t" : "/__tfs__"
exe = windows ? ".exe" : ""
version = tebako.fetch("version")

asset = ->(name) { "#{name}-#{version}-#{tool}#{exe}" }

pairs = {
  "TEBAKO_VERSION" => version,
  "TEBAKO_RELEASE" => tebako.fetch("release"),
  "TEBAKO_PKG_ASSET" => asset.call("tebako-pkg"),
  "TEBAKO_PKG_SHA256" => tool_sha.call("tebako-pkg"),
  "TEBAKO_BOOTSTRAP_ASSET" => asset.call("tebako-bootstrap"),
  "TEBAKO_BOOTSTRAP_SHA256" => tool_sha.call("tebako-bootstrap"),
  "TFS_ASSET" => asset.call("tfs"),
  "TFS_SHA256" => tool_sha.call("tfs"),
  "RUNTIME_REF" => "ruby@#{runtime.fetch('ruby')};tebako=#{runtime.fetch('tebako')};image",
  "RUNTIME_RUBY" => runtime.fetch("ruby"),
  "RUNTIME_TEBAKO" => runtime.fetch("tebako"),
  "PKG_VERSION" => package.fetch("version"),
  "RUNTIME_ROOT" => runtime_root,
  "LAUNCHER_ABI" => "1",
  "EXE_SUFFIX" => exe,
  "MN_RELEASE" => mn_p.fetch("release"),
  "MN_FILE" => mn.fetch("file"),
  "MN_SHA256" => mn.fetch("sha256"),
  "JDK_RELEASE" => jdk_p.fetch("release"),
  "JDK_FILE" => jdk.fetch("file"),
  "JDK_SHA256" => jdk.fetch("sha256"),
  "INK_RELEASE" => ink_p.fetch("release"),
  "INK_FILE" => ink.fetch("file"),
  "INK_SHA256" => ink.fetch("sha256"),
}

if ARGV.include?("--env")
  pairs.each { |k, v| puts "#{k}=#{v}" }
else
  pairs.each { |k, v| puts "export #{k}=#{v}" }
end
