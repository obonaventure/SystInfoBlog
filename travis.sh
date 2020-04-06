#!/bin/bash

mdspell -n -a -r -d /usr/share/hunspell/fr _posts/*
jekyll build .
