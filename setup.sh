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
