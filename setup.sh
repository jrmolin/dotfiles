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

install_dot() {
  NAME=`basename $1`
  isdir=$2

    if [ "x$isdir" != "x" ] ; then
      if [ -e "$HOME/.${NAME}" ]; then
        doit mv "$HOME/.${NAME}" "$HOME/.${NAME}.bkup"
      fi
    else
      if [ -e "$HOME/.${NAME}" ]; then
        doit mv "$HOME/.${NAME}" "$HOME/.${NAME}.bkup"
      fi
    fi

    doit ln -s $WORKDIR/$1 "$HOME/.${NAME}"
}

install_dot vim/vim true
install_dot vim/vimrc
install_dot tmux/tmux.conf
install_dot bash/bash_aliases
install_dot bash/bashrc
install_dot bash/bash_functions

link_file $WORKDIR/bash/dircolors "$HOME/.dircolors"
