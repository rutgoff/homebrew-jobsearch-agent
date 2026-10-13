"""Checks that each installed package has the version that the release pinned.

Run it with the Python of the formula:
"$(brew --prefix rutgoff/jobsearch-agent/jobsearch)/libexec/bin/python" test/check_pins.py "$(brew --cache rutgoff/jobsearch-agent/jobsearch)"
"""

import importlib.metadata
import platform
import re
import sys
import zipfile

PIN = re.compile(r"^([A-Za-z0-9._-]+)==([^\s;]+)")
# cryptography 49 and later ship no Intel macOS wheel; the formula installs 48.0.1 there.
INTEL_MAC_EXCEPTIONS = {"cryptography": "48.0.1"}


def normalize(name):
    return re.sub(r"[-_.]+", "-", name).lower()


def exceptions(system, machine):
    """Return the allowed differences from the pins on this system (Intel Macs only)."""
    return INTEL_MAC_EXCEPTIONS if system == "darwin" and machine == "x86_64" else {}


def wrong_pins(pins, installed, system=sys.platform, machine=platform.machine()):
    """Return 1 line for each installed package whose version differs from its pin."""
    allowed = exceptions(system, machine)
    return [
        f"{name} {version} (pinned {pins[name]})"
        for name, version in sorted(installed.items())
        if pins.get(name, version) != version and allowed.get(name) != version
    ]


def main(wheel):
    text = (
        zipfile.ZipFile(wheel).read("job_search_agent/release_constraints.txt").decode()
    )
    pins = {
        normalize(match[1]): match[2]
        for match in map(PIN.match, text.splitlines())
        if match
    }
    installed = {
        normalize(dist.metadata["Name"]): dist.version
        for dist in importlib.metadata.distributions()
    }
    wrong = wrong_pins(pins, installed)
    for line in wrong:
        print(line)
    allowed = sorted(set(exceptions(sys.platform, platform.machine())) & set(installed))
    note = f", {len(allowed)} allowed exception ({', '.join(allowed)})" if allowed else ""
    print(f"{len(pins)} pins, {len(wrong)} wrong{note}")
    return 1 if wrong else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
