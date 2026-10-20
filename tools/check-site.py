#!/usr/bin/env python3
"""Compare the CV's papers with the website's research/papers.yml.

Usage: tools/check-site.py cv-content.tex ../rrmaximiliano.github.io/research/papers.yml

Matches titles ignoring case and punctuation, and checks
that each paper is in the matching section (working paper, in progress,
...). Prints what differs; exits 1 if anything does.
"""
import re
import sys

# On the CV on purpose, not on the website.
CV_ONLY = {
    "Shifting Governance: Assessing the Impact of Chile's Educational "
    "Integration Reforms on School and Student Outcomes",
    "Who Learns What? Combining Causal Forests and IRT in an Online "
    "Tutoring RCT for Ukrainian Students",
}

# CV section (\cvdefine key) -> website groups it covers.
SECTIONS = {
    "publications": {"published-papers", "published-chapters"},
    "working": {"working"},
    "progress": {"progress"},
    "predoc": {"predoc-books", "predoc-papers", "predoc-reports"},
}


def norm(title):
    title = re.sub(r"\\[A-Za-z]+", "", title)  # TeX commands
    return re.sub(r"[\W_]+", "", title.lower())


def braced(text, i):
    """Return the {...} group starting at text[i] and the index after it."""
    depth = 0
    for j in range(i, len(text)):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[i + 1 : j], j + 1
    raise ValueError("unbalanced braces")


def cv_papers(path):
    text = open(path, encoding="utf-8").read()
    text = re.sub(r"(?<!\\)%.*", "", text)  # comments
    papers, section = {}, None
    for m in re.finditer(r"\\cvdefine\{(\w+)\}|\\cvpub(?:\[[^\]]*\])?\s*", text):
        if m.group(1):
            section = m.group(1)
            continue
        title, _ = braced(text, m.end())
        title = " ".join(title.split())
        papers[norm(title)] = (title, section)
    return papers


def site_papers(path):
    papers, title = {}, None
    for line in open(path, encoding="utf-8"):
        m = re.match(r'-\s+title:\s*"?(.*?)"?\s*$', line)
        if m:
            title = m.group(1)
        m = re.match(r"\s+group:\s*(\S+)", line)
        if m and title:
            papers[norm(title)] = (title, m.group(1))
            title = None
    return papers


def main(cv_path, site_path):
    cv, site = cv_papers(cv_path), site_papers(site_path)
    only_cv = {norm(t) for t in CV_ONLY}
    problems = []
    for key, (title, group) in site.items():
        if key not in cv:
            problems.append(f"On the website, not in the CV: {title}")
        elif group not in SECTIONS.get(cv[key][1], set()):
            problems.append(
                f"Different section: {title}\n"
                f"    CV: {cv[key][1]}; website: {group}")
    for key, (title, _) in cv.items():
        if key not in site and key not in only_cv:
            problems.append(f"In the CV, not on the website: {title}")
    for p in problems:
        print(p)
    print(f"{len(cv)} CV papers, {len(site)} website papers, "
          f"{len(problems)} difference(s).")
    return 1 if problems else 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2])
    sys.exit(main(sys.argv[1], sys.argv[2]))
