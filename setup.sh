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

setup_vim() {
    doit mkdir -pv "vim/vim/autoload" "vim/vim/bundle"

    doit curl -LSso vim/vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
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

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

doit git submodule init
doit git submodule update

install_sqlite

install_curl
install_vim
setup_vim
install_tmux

if [ -e "$HOME/.vimrc" ]; then
    doit mv "$HOME/.vimrc" "$HOME/.vimrc.bkup"
fi

if [ -d "$HOME/.vim" ]; then
    doit mv "$HOME/.vim" "$HOME/.vim.bkup"
fi

doit ln -s $WORKDIR/vim/vim "$HOME/.vim"
doit ln -s $WORKDIR/vim/vimrc "$HOME/.vimrc"
doit ln -s $WORKDIR/tmux/tmux.conf "$HOME/.tmux.conf"
doit ln -s $WORKDIR/bash/bashrc "$HOME/.bashrc"
doit ln -s $WORKDIR/bash/bash_aliases "$HOME/.bash_aliases"
