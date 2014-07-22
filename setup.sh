#!/bin/bash

doit() {
    if [ "x$DEBUG" = "x1" ]; then
        echo "$@"
    fi

#    eval "$@"
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

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR

doit git submodule init
doit git submodule update

if [ -e "$HOME/.vimrc" ]; then
    doit mv "$HOME/.vimrc" "$HOME/.vimrc.bkup"
fi
doit cp vim/vimrc "$HOME/.vimrc"

if [ -d "$HOME/.vim" ]; then
    doit mv "$HOME/.vim" "$HOME/.vim.bkup"
fi

doit cp -r vim/vim "$HOME/.vim"
doit mv "$HOME/.vim/autoload/autoload/pathogen.vim" "$HOME/.vim/autoload/"
doit rm -rf "$HOME/.vim/autoload/autoload"
