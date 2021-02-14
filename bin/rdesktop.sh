#!/bin/sh
USERNAME=focal

RESOLUTION=1296x1024
RESOLUTION=1024x768

rdesktop \
 $1 \
 -u $USERNAME \
 -k ja \
 -r clipboard \
 -r disk:share=$HOME/Downloads \
 -g $RESOLUTION -T "_"
 #-a 16 \
 #-f
