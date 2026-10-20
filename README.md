# rrmrr-vita

The LaTeX source of my CV. The PDF is published with GitHub Pages at
[rrmaximiliano.com/rrmrr-vita/rrmrr-vita.pdf](https://www.rrmaximiliano.com/rrmrr-vita/rrmrr-vita.pdf)
and shown on [rrmaximiliano.com/cv](https://www.rrmaximiliano.com/cv/).

The design started from Kieran Healy's
[kjh-vita](https://github.com/kjhealy/kjh-vita) (see
[how this compares](#how-this-compares-to-kjh-vita)), with my own layout
macros, fonts, and publishing setup.

## Updating the CV

```sh
make hooks    # once per clone: turn on the git hooks in hooks/
# edit cv-content.tex
make          # optional: build the PDF to check it
make sync     # optional: compare the papers with the website
git commit    # the post-commit hook builds the PDF and commits it
git push      # GitHub Pages publishes the PDF; the website picks it up
```

There is no separate build step before publishing. After any commit that
changes the CV source, the hook builds the PDF and adds a second commit,
"Build CV from `abc1234`", with the PDF and `rrmrr-vita.json`.

## The full CV and shorter versions

All content lives in `cv-content.tex`, once. Each version is a short file
that picks sections and their order:

| File | Pages | Build | What it is |
|---|---|---|---|
| `rrmrr-vita.tex` | 5 | `make` (and the hook) | The full CV, in the order the department recommends. The only PDF that is committed and published. |
| `rrmrr-vita-short.tex` | 3 | `make short` | The short CV. |
| `rrmrr-vita-lemann.tex` | 3 | `make lemann` | The short CV with grants and research first, for the Lemann proposal. |

The short versions are built only when needed, from the same content, so
they are never out of date. Their PDFs stay on your computer: git ignores
them, and they are not published.

The short versions call `\cvshort`, which leaves out every entry wrapped in
`\fullonly{...}` (older talks, minor awards and teaching), runs courses and
grant details together on one line, and tightens the spacing. To drop
something from the short CV, wrap it in `\fullonly`; to add a new version,
copy `rrmrr-vita-short.tex` and change its `\cvshow` list.

`\cvshow[Label]{key}` prints a section; `\cvshow{grants,awards}` prints two
as one. These files do the job of the old `2-page` and
`dev/lemann-three-page-cv` branches, without a second copy of the content
that can fall out of date.

## Requirements

- XeLaTeX and `latexmk` (MacTeX).
- Fonts: Minion Pro (text), Lexia Mono (monospace), and FontAwesome
  (GitHub icons). Minion Pro and Lexia Mono come from Adobe Fonts.
- For `make sync` and `make links`: Python 3 and `curl` (both come with
  macOS).

The PDF is built on my Mac, not by GitHub Actions: Adobe Fonts can't be
installed on GitHub's servers, so a cloud build would need different fonts.
The git hooks automate the local build instead. The catch is that an edit
made on github.com doesn't rebuild the PDF; the next commit from my Mac does.

## How publishing works

```
commit .tex ──► post-commit hook ──► make release ──► commit PDF + JSON
                                                            │
git push ──► pre-push hook (make check) ──► GitHub Pages serves both files
                                                            │
rrmaximiliano.com/cv ◄── reads rrmrr-vita.json in the browser
```

- `hooks/post-commit` runs `make release` when a commit touches the CV
  source (`*.tex`, `*.sty`, `logo/`). It skips rebases, merges, and
  cherry-picks; commit again or run `make release` afterwards. If the build
  fails, it says so and leaves the log in `/tmp/rrmrr-vita-release.log`.
- `hooks/pre-push` runs `make check` and blocks the push if the committed PDF
  wasn't built from the latest source. Fix it with `make release`, or skip
  the check with `git push --no-verify`.
- GitHub Pages serves the `master` branch, so `rrmrr-vita.pdf` and
  `rrmrr-vita.json` go live a few minutes after a push.
- The website's CV page fetches `rrmrr-vita.json` when someone opens it and
  shows the same line as the PDF footer. The website never needs to be
  re-rendered for a CV update.

## The version stamp

The footer of page 1 reads "Updated with commit `abc1234` on October 19,
2026", with the hash linked to that commit on GitHub.

`latexmk` runs `vc.sh` before every build (see `.latexmkrc`). `vc.sh` asks
git for the last commit that changed the CV source and writes:

- `vc.tex` (git-ignored), which `rrmrr-cv.sty` reads to define
  `\cvcommit`, `\cvcommitfull`, and `\cvdate`;
- `rrmrr-vita.json`, the same commit and date for the website.

Two details make the stamp trustworthy:

- **It is the last source commit, not `HEAD`.** The PDF is committed after
  the source, so `HEAD` would move every time the PDF is committed. Using the
  last commit that touched the source means the hash in a released PDF points
  to the exact `.tex` that produced it.
- **The date is when the content changed, not when the PDF was compiled.**
  Rebuilding the same source gives the same date. A build with uncommitted
  edits (`make` while editing) uses today's date instead.

If git isn't available, the footer falls back to "Updated on" and the build
date.

## Make targets

| Target | What it does |
|---|---|
| `make` | Builds the full CV (`latexmk -xelatex`). |
| `make short`, `make lemann` | Builds a short version (not committed). |
| `make release` | Builds the full CV from committed source and commits the PDF and JSON. Refuses if the source has uncommitted edits. |
| `make check` | Fails if the committed PDF is older than the source. |
| `make sync` | Lists papers that differ between the CV and the website's `research/papers.yml` (title or section). Papers that are on the CV on purpose are listed in `tools/check-site.py`. |
| `make links` | Checks every link in the CV. Fails on links that are gone; lists sites that refuse scripts or time out, to open by hand. |
| `make hooks` | Points git at `hooks/` (`core.hooksPath`). |
| `make clean` | Removes LaTeX build files and `vc.tex`. |

## Files

| File | Purpose |
|---|---|
| `cv-content.tex` | Everything the CV says: personal details and every section. |
| `rrmrr-vita.tex`, `rrmrr-vita-short.tex`, `rrmrr-vita-lemann.tex` | The versions: which sections, in what order. |
| `rrmrr-cv.sty` | Packages, fonts, layout macros, header, footer, and the version stamp. |
| `vc.sh` | Writes `vc.tex` and `rrmrr-vita.json` from git. |
| `.latexmkrc` | Uses XeLaTeX and runs `vc.sh` before each build. |
| `hooks/` | `post-commit` (build and commit the PDF) and `pre-push` (check). |
| `tools/` | The scripts behind `make sync` and `make links`. |
| `rrmrr-vita.pdf`, `rrmrr-vita.json` | Build outputs, committed so GitHub Pages can serve them. |
| `logo/` | Harvard logo for the header. |

## Layout macros

Every entry uses one of these, so spacing and indents stay consistent. Section
labels sit in the left column (26% of the text width); entry titles start the
right column and detail lines are indented 1em below them, in small type.
The gaps are three lengths in `rrmrr-cv.sty`: `\cvgap` (4pt, after each
entry), `\cvsubgap` (2pt, between a title and its details), and
`\cvheadgap` (3pt, below a group heading).

| Macro | Use |
|---|---|
| `\cvdefine{key}{Label}{...}` | Stores a section in `cv-content.tex`; prints nothing. |
| `\cvshow[Label]{key}` | Prints a stored section, or several (`grants,awards`) as one. |
| `\cvitem{Title}{Details}{Date}` | A standard entry; details and date are optional. |
| `\cvsubitem{Title}{Detail}{Date}` | A line inside an entry, e.g. a course with its instructor below. |
| `\cvgrant{Funder}{Amount}{Project}{Co-PIs}{Year}` | A grant; project and co-PIs are optional. |
| `\cvpub[URL]{Title}{Authors}{Venue}{Year}` | A paper: title (quoted, linked to URL) and year, then authors and venue on one line. |
| `\cvsubheading{Name}` | A group inside a section, e.g. Journal Articles. |
| `\cvitemconf{Text}{Year}` | A talk; the year stays aligned when the text wraps. |
| `\me` | My name in bold, for author lists. |
| `\fullonly{...}` | Content left out of the short versions. |

Content can't contain a bare `#`; write `\#`, also inside URLs.

Typography rules:

- **Bold**: section labels, and my name in author lists.
- *Italic*: group headings, journal and book titles, supervisors and
  instructors, and the `&` in titles (`\textit{\&}`).
- Regular: every entry title.
- Small: detail lines and dates. Detail lines have no final period.
- Monospace: contact details, package names, and the footer.

## How this compares to kjh-vita

The version stamp follows Healy's idea. kjh-vita uses the CTAN
[`vc`](https://ctan.org/pkg/vc) package: a script reads `git log` and writes
`vc.tex`, the vita does `\input{vc}`, and the footer prints the revision. This
repo does the same with `vc.sh` and `vc.tex`. An earlier version of this CV
read `.git/HEAD` from LaTeX instead, which broke on packed refs and in git
worktrees, and showed the compile date.

What differs:

| | kjh-vita | This repo |
|---|---|---|
| Stamp | `vc` package script | `vc.sh`, no package needed |
| When the script runs | By hand, or via `\write18` with `--shell-escape` | Automatically by `latexmk`, before every build |
| Commit shown | `HEAD` | The last commit that changed the CV source |
| Date shown | Commit date | Commit date (today's date for uncommitted edits) |
| Building and publishing | Manual | Git hooks build and commit the PDF; `git push` publishes it |
| Website | Links to the PDF | Also reads `rrmrr-vita.json` to show the same commit and date |
| Layout | `memoir` with Healy's styles | `article` with the macros above |
| Content | In the vita file | In `cv-content.tex`, shared by the full CV and the short versions |
