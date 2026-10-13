require_relative "../lib/jobsearch_key_download_strategy"

class Jobsearch < Formula
  desc "AI assistant that finds, scores, and tracks job postings"
  homepage "https://github.com/rutgoff/job-search-agent-preview"
  url "https://software.utgoff.org/jobsearch/job_search_agent-1.2.0-py3-none-any.whl",
      using: JobsearchKeyDownloadStrategy
  sha256 "eca09203b6d3b6a928c8d55c40bcda4707a8ecbfc57202fccf32805d4942aa20"
  license "MIT"

  depends_on "python@3.12"

  # Prebuilt wheels (for example jiter) have `@rpath` dylib IDs and no header room for an absolute path.
  preserve_rpath

  def install
    python = formula_opt_bin("python@3.12")/"python3.12"
    wheel = buildpath/"job_search_agent-#{version}-py3-none-any.whl"
    constraints = buildpath/"constraints.txt"
    pins = Utils.safe_popen_read(python, "-c", <<~PYTHON, wheel)
      import sys, zipfile
      data = zipfile.ZipFile(sys.argv[1]).read("job_search_agent/release_constraints.txt")
      sys.stdout.write(data.decode())
    PYTHON
    if OS.mac? && Hardware::CPU.intel?
      # cryptography 49 and later ship no Intel macOS wheel; 48.0.1 is the last one.
      pins = pins.lines.grep_v(/\Acryptography==/).join + "cryptography==48.0.1\n"
    end
    constraints.write pins
    overrides = buildpath/"overrides.txt"
    overrides.write <<~EOS
      lancedb; sys_platform == 'never'
      onnxruntime; sys_platform == 'never'
    EOS

    # uv from PyPI, pinned by hash: the uv formula builds Rust and LLVM from source on an Intel Mac.
    uv_requirements = buildpath/"uv-requirements.txt"
    uv_requirements.write <<~EOS
      uv==0.12.3 \\
        --hash=sha256:0550669163cc67d5a7dc8e1702bc011e4a075a4ae52ad50891be654fc6635e0d \\
        --hash=sha256:7c99f2524fe4b11d74dec85cef9b4d8b725d142dec04cd237f1c06fbdae1ee54 \\
        --hash=sha256:1482d1462b1aecd18ee33627363fe1c63d6a194f12d40d37efc446d9e0d800a1 \\
        --hash=sha256:ac21bea426ddf95fa76d8dc1f67350faed7b4a81951825cf2aaef99fc4144815 \\
        --hash=sha256:13535c7d40faa7821c3763f5b6c605eef8556ea16277dc1a07a21203fd3c19e4
    EOS
    tools = buildpath/"tools"
    system python, "-m", "venv", tools
    system tools/"bin/python", "-m", "pip", "install", "--disable-pip-version-check", "--no-cache-dir",
           "--only-binary", ":all:", "--require-hashes", "--requirement", uv_requirements
    uv = tools/"bin/uv"

    ENV["UV_CACHE_DIR"] = buildpath/"uv-cache"
    ENV["UV_PYTHON_DOWNLOADS"] = "never"
    ENV["UV_NO_CONFIG"] = "1"
    ENV["UV_LINK_MODE"] = "copy"
    system uv, "venv", "--python", python, libexec
    system uv, "pip", "install", "--python", libexec/"bin/python",
           "--constraint", constraints, "--override", overrides, wheel
    bin.install_symlink libexec/"bin/jobsearch"
  end

  test do
    assert_match "jobsearch #{version}", shell_output("#{bin}/jobsearch version")
  end
end
