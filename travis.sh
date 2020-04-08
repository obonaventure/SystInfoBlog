#!/bin/bash
mdspell --version
find /usr -name "fr.dic"
mdspell --ignore-numbers --ignore-acronyms --report --no-suggestions --dictionary /usr/share/hunspell/fr README.md _posts/*.md
jekyll build .
