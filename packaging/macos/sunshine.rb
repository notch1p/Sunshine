require "language/node"

class Sunshine < Formula
  desc "Gamestream host/server for Moonlight"
  homepage "https://app.lizardbyte.dev"
  url "/Users/notch1p/dockFolders/playground/Sunshine",
      # is tag required? won't be available until after a release is published
      commit: "ce3b625"
  license "GPL-3.0-only"
  version "ce3b625"
  head "https://github.com/LizardByte/Sunshine.git", branch: "nightly"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "curl"
  depends_on "miniupnpc"
  depends_on "node"
  depends_on "openssl"
  depends_on "opus"

  def install
    system "git", "submodule", "update", "--remote", "--init", "--recursive", "--depth", "1"
    # Fix https://github.com/LizardByte/Sunshine/discussions/391#discussioncomment-8689960
    # system "sed", "-i", "''", "s/SUNSHINE_SOURCE_ASSETS_DIR=${SUNSHINE_SOURCE_ASSETS_DIR} SUNSHINE_ASSETS_DIR=${CMAKE_BINARY_DIR}//", "cmake/targets/common.cmake"

    args = %W[
      -DBUIld_WERROR=ON
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DOPENSSL_ROOT_DIR=#{Formula["openssl"].opt_prefix}
    ]
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args

    cd "build" do
      system "make", "-j"
      system "make", "install"
    end
  end

  service do
    run [opt_bin/"sunshine", "~/.config/sunshine/sunshine.conf"]
  end
  test do
    # test that version numbers match
    assert_match "Sunshine version: v0.22.0", shell_output("#{bin}/sunshine --version").strip
  end
end