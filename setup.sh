#!/bin/bash
DEBUG=1


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
    doit mkdir -pv "vim/vim/autoload" "vim/vim/bundle"

    doit curl https://tpo.pe/pathogen.vim > "vim/vim/autoload/pathogen.vim"
}

# install curl
install_curl() {
    local CURL=`which curl`

    if [ "x$CURL" = "x" ]; then
        doit sudo apt-get install -y curl
    fi

}

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

doit git submodule init
doit git submodule update

install_curl
install_vim
setup_vim

if [ -e "$HOME/.vimrc" ]; then
    doit mv "$HOME/.vimrc" "$HOME/.vimrc.bkup"
fi

if [ -d "$HOME/.vim" ]; then
    doit mv "$HOME/.vim" "$HOME/.vim.bkup"
fi

doit ln -s $WORKDIR/vim/vim "$HOME/.vim"
doit ln -s $WORKDIR/vim/vimrc "$HOME/.vimrc"
