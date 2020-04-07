#!/bin/bash
mdspell -V 
find /usr -name "fr.dic"
mdspell -n -a -r -d /usr/share/hunspell/fr _posts/*
jekyll build .
