#!/bin/bash
DEBUG=1


doit() {
    if [ "x$DEBUG" = "x1" ]; then
        echo "$@"
    fi

    eval "$@"
}

# install sqlite stuff
install_sqlite() {
    local VIM=`which sqlite`

    if [ "x$SQLITE" = "x" ]; then
        doit sudo apt-get install -y sqlite3
    fi
}

# install vim stuff
install_vim() {
    local VIM=`which vim`

    if [ "x$VIM" = "x" ]; then
        doit sudo apt-get install -y vim
    fi
}

# install tmux
install_tmux() {
    local TMUX=`which tmux`

    if [ "x$TMUX" = "x" ]; then
        doit sudo apt-get install -y tmux
    fi
}

# install curl
install_curl() {
    local CURL=`which curl`

    if [ "x$CURL" = "x" ]; then
        doit sudo apt-get install -y curl
    fi

}

link_file() {
    if [ -e $1 ]; then
        doit mv $1 "${1}.bkup"
    fi

    doit ln -s "$1" "$2"
}

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

doit git submodule init
doit git submodule update

install_sqlite

install_curl
install_vim
install_tmux

if [ -e "$HOME/.vimrc" ]; then
    doit mv "$HOME/.vimrc" "$HOME/.vimrc.bkup"
fi

if [ -d "$HOME/.vim" ]; then
    doit mv "$HOME/.vim" "$HOME/.vim.bkup"
fi

link_file $WORKDIR/vim/vim "$HOME/.vim"
link_file $WORKDIR/vim/vim "$HOME/.vim"
link_file $WORKDIR/vim/vimrc "$HOME/.vimrc"
link_file $WORKDIR/tmux/tmux.conf "$HOME/.tmux.conf"
link_file $WORKDIR/bash/bashrc "$HOME/.bashrc"
link_file $WORKDIR/bash/bash_aliases "$HOME/.bash_aliases"
link_file $WORKDIR/bash/bash_functions "$HOME/.bash_functions"
link_file $WORKDIR/bash/dircolors "$HOME/.dircolors"
