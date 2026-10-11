require_relative "../lib/jobsearch_key_download_strategy"

class Jobsearch < Formula
  desc "AI assistant that finds, scores, and tracks job postings"
  homepage "https://github.com/rutgoff/job-search-agent-preview"
  url "https://software.utgoff.org/jobsearch/job_search_agent-1.2.0-py3-none-any.whl",
      using: JobsearchKeyDownloadStrategy
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on "uv" => :build
  depends_on "python@3.12"

  def install
    python = formula_opt_bin("python@3.12")/"python3.12"
    wheel = buildpath/"job_search_agent-#{version}-py3-none-any.whl"
    constraints = buildpath/"constraints.txt"
    constraints.write Utils.safe_popen_read(python, "-c", <<~PYTHON, wheel)
      import sys, zipfile
      data = zipfile.ZipFile(sys.argv[1]).read("job_search_agent/release_constraints.txt")
      sys.stdout.write(data.decode())
    PYTHON
    overrides = buildpath/"overrides.txt"
    overrides.write <<~EOS
      lancedb; sys_platform == 'never'
      onnxruntime; sys_platform == 'never'
    EOS

    ENV["UV_CACHE_DIR"] = buildpath/"uv-cache"
    ENV["UV_PYTHON_DOWNLOADS"] = "never"
    ENV["UV_NO_CONFIG"] = "1"
    ENV["UV_LINK_MODE"] = "copy"
    uv = formula_opt_bin("uv")/"uv"
    system uv, "venv", "--python", python, libexec
    system uv, "pip", "install", "--python", libexec/"bin/python",
           "--constraint", constraints, "--override", overrides, wheel
    bin.install_symlink libexec/"bin/jobsearch"
  end

  test do
    assert_match "jobsearch #{version}", shell_output("#{bin}/jobsearch version")
  end
end
