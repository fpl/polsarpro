#!/bin/sh
# Removes all not-Linux related files.
#
find . -name '*.exe' -print -delete
find . -name '*.dll' -print -delete
find . -name '*.obj' -print -delete
find . -name '*.bak' -print -delete
find . -name '*.win' -print -delete
find . -name '*.bat' -print -delete
