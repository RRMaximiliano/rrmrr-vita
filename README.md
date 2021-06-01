# Latex template for CV

Based on  [Kieran Healy's CV](https://kieranhealy.org/vita.pdf) with edits (git, fonts, spacing, etc.)

Fonts use:

1. Minion Pro.
2. JetBrains Mono
3. Unit-Medium

Git setup:

```tex
% Two required libraries
\usepackage{xstring}
\usepackage{catchfile}

% Set user input
\newcommand{\gitfolder}{.git}                             % Relative path to .git folder from .tex file
\newcommand{\reponame}{rrmaximiliano/rrmrr-tex}           % Name of account and repo. Will be included in URL

% Based on this https://tex.stackexchange.com/questions/455396/how-to-include-the-current-git-commit-id-and-branch-in-my-document
\CatchFileDef{\headfull}{\gitfolder/HEAD.}{}              % Get path to head file for checked out branch
\StrGobbleRight{\headfull}{1}[\head]                      % Remove end of line character
\StrBehind[2]{\head}{/}[\branch]                          % Parse out the path only
\CatchFileDef{\commit}{\gitfolder/refs/heads/\branch.}{}  % Get the content of the branch head
\StrGobbleRight{\commit}{1}[\commithash]                  % Remove end of line character
\StrLeft{\commithash}{7}[\commitsix]                      % Get a 7 hex commit code

% Build the commit based on the information we now have
\newcommand{\commitcode}{\texttt{\commitsix}}
```
