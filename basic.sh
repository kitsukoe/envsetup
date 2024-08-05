#!/bin/bash

# If not already sudoed, sudo
if [ "$EUID" -ne 0 ]; then
    sudo "$0" "$@"
    exit
fi