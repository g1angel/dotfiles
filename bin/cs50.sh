#!/bin/bash

# configure prompt
if [ "$PS1" ]; then
    export PS1="\u@\h (\w): "
fi

export NODE_PATH=$NODE_PATH:/usr/lib/node_modules/npm/node_modules/

# configure clang
export CC=clang
export CFLAGS="-ggdb -O0 -std=c99 -Wall -Werror"
export LDLIBS="-lcs50 -lm"

# protect user
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# allow core dumps
ulimit -c unlimited

echo "Entering cs50 environment."

bash

