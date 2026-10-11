"""Checks that each installed package has the version that the release pinned.

Run it with the Python of the formula:
"$(brew --prefix jobsearch)/libexec/bin/python" test/check_pins.py "$(brew --cache jobsearch)"
"""

import importlib.metadata
import re
import sys
import zipfile

PIN = re.compile(r"^([A-Za-z0-9._-]+)==([^\s;]+)")


def normalize(name):
    return re.sub(r"[-_.]+", "-", name).lower()


def main(wheel):
    text = (
        zipfile.ZipFile(wheel).read("job_search_agent/release_constraints.txt").decode()
    )
    pins = {
        normalize(match[1]): match[2]
        for match in map(PIN.match, text.splitlines())
        if match
    }
    wrong = []
    for dist in importlib.metadata.distributions():
        name = normalize(dist.metadata["Name"])
        if pins.get(name, dist.version) != dist.version:
            wrong.append(
                f"{dist.metadata['Name']} {dist.version} (pinned {pins[name]})"
            )
    for line in wrong:
        print(line)
    print(f"{len(pins)} pins, {len(wrong)} wrong")
    return 1 if wrong else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
