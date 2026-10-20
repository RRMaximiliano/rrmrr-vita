CV := rrmrr-vita
SRC := '*.tex' '*.sty' logo

.PHONY: pdf release check hooks clean

# Build the PDF. With uncommitted edits, the footer shows the last commit and
# today's date; use `make release` for a PDF that matches its commit exactly.
pdf:
	latexmk -xelatex -interaction=nonstopmode $(CV).tex

# Build from committed source and commit the PDF, so the commit in the footer
# is exactly the source of the published PDF. The post-commit hook runs this
# for you after every commit that changes the CV source.
release:
	@git diff --quiet HEAD -- $(SRC) || { echo "Commit the CV source first."; exit 1; }
	latexmk -xelatex -interaction=nonstopmode $(CV).tex
	git add $(CV).pdf $(CV).json
	@git diff --cached --quiet -- $(CV).pdf $(CV).json \
	  || git commit -m "Build CV from $$(git log -1 --format=%h -- $(SRC))"

# Fails if the committed PDF wasn't built from the latest source commit.
# The pre-push hook runs this.
check:
	@src=$$(git log -1 --format=%H -- $(SRC)); \
	git show HEAD:$(CV).json 2>/dev/null | grep -q "$$src" \
	  || { echo "The committed PDF is older than the CV source. Run: make release"; exit 1; }

# Use the hooks in hooks/ (once per clone).
hooks:
	git config core.hooksPath hooks

clean:
	latexmk -c $(CV).tex
	rm -f vc.tex
