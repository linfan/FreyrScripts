#!/usr/bin/env bash

if [ "$TMUX" = "" ]; then
    tmux a
    if [ "$?" = "1" ]; then
        tmux
    fi
fi
