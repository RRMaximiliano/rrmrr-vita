CV := rrmrr-vita
# Short versions: built on request (make short, make lemann), not committed.
VARIANTS := $(CV)-short $(CV)-lemann
SRC := '*.tex' '*.sty' logo
SITE ?= ../rrmaximiliano.github.io
LATEXMK := latexmk -xelatex -interaction=nonstopmode

.PHONY: pdf short lemann release check links sync hooks clean

# Build the full CV. With uncommitted edits, the footer shows the last
# commit and today's date; use `make release` for a PDF that matches a commit.
pdf:
	$(LATEXMK) $(CV).tex

# Build a short version when you need it. Its PDF stays local (.gitignore).
short:
	$(LATEXMK) $(CV)-short.tex

lemann:
	$(LATEXMK) $(CV)-lemann.tex

# Build the full CV from committed source and commit the PDF, so the commit
# in the footer is exactly the source of the published PDF. The post-commit
# hook runs this for you after every commit that changes the CV source.
release:
	@git diff --quiet HEAD -- $(SRC) || { echo "Commit the CV source first."; exit 1; }
	$(LATEXMK) $(CV).tex
	git add $(CV).pdf $(CV).json
	@git diff --cached --quiet -- $(CV).pdf $(CV).json \
	  || git commit -m "Build CV from $$(git log -1 --format=%h -- $(SRC))"

# Fails if the committed PDF wasn't built from the latest source commit.
# The pre-push hook runs this.
check:
	@src=$$(git log -1 --format=%H -- $(SRC)); \
	git show HEAD:$(CV).json 2>/dev/null | grep -q "$$src" \
	  || { echo "The committed PDF is older than the CV source. Run: make release"; exit 1; }

# Lists links in the CV that are gone or need a look in a browser.
links:
	@tools/check-links.sh cv-content.tex

# Compares the CV's papers with the website's research/papers.yml.
sync:
	@tools/check-site.py cv-content.tex $(SITE)/research/papers.yml

# Use the hooks in hooks/ (once per clone).
hooks:
	git config core.hooksPath hooks

clean:
	latexmk -c $(CV).tex $(VARIANTS:=.tex)
	rm -f vc.tex
