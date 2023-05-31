#! /usr/bin/bash

fff() {
    fff-script "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

