#!/bin/bash

doit() {
    if [ "x$DEBUG" = "x1" ]; then
        echo "$@"
    fi

    eval "$@"
}

# install vim stuff
install_vim() {
    local VIM=`which vim`

    if [ "x$VIM" = "x" ]; then
        doit sudo apt-get install -y vim
    fi
}

setup_vim() {
    doit mkdir -pv "${HOME}/.vim/autoload" "${HOME}/.vim/bundle"

    doit curl https://tpo.pe/pathogen.vim > "${HOME}/.vim/autoload/pathogen.vim"
}

# install curl
install_curl() {
    local CURL=`which curl`

    if [ "x$CURL" = "x" ]; then
        doit sudo apt-get install -y curl
    fi

}

install_curl
install_pathogen
