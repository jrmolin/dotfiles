#!/bin/bash
DEBUG=1

getsystem() {
    local _system="debian"

    if [ -e "/etc/fedora-release" ]
    then
        _system="fedora"
    elif [ -e "/etc/redhat-release" ]
    then
        _system="redhat"
    else
        local _uname=$(uname)
        if [ "x$_uname" = "xDarwin" ]
        then
            _system="macos"
        fi
    fi

    echo $_system
}

setup() {

    if [ "x$_SYSTEM" = "xfedora" ]
    then
        INSTALL="dnf install -y"
    elif [ "x$_SYSTEM" = "xredhat" ]
    then
        INSTALL="dnf install -y"
    elif [ "x$_SYSTEM" = "xmacos" ]
    then
        INSTALL="brew install"
    elif [ "x$_SYSTEM" = "xdebian" ]
    then
        INSTALL="apt install -y"
    fi
    echo $INSTALL
}


doit() {
    if [ "x$DEBUG" = "x1" ]; then
        echo "$@"
    fi

    eval "$@"
}

# install sqlite stuff
install_sqlite() {
    local _sqlite=$(which sqlite3)
    if [ -e "$_sqlite" ]
    then
        return
    fi

    local _package="sqlite3"

    if [ "x$_SYSTEM" = "fedora" ]
    then
        _package="sqlite"
    elif [ "x$_SYSTEM" = "redhat" ]
    then
        _package="sqlite"
    fi

    if [ "x$SQLITE" = "x" ]; then
        doit sudo $INSTALL $_package
    fi
}

# install vim stuff
install_vim() {
    local VIM=$(which vim)

    if [ "x$VIM" = "x" ]; then
        doit sudo $INSTALL vim
    fi
}

# install tmux
install_tmux() {
    local TMUX=$(which tmux)

    if [ "x$TMUX" = "x" ]; then
        doit sudo $INSTALL tmux
    fi
}

# install curl
install_curl() {
    local CURL=$(which curl)

    if [ "x$CURL" = "x" ]; then
        doit sudo $INSTALL curl
    fi

}

# install stow
install_stow() {
    local _stow=$(which stow)

    if [ "x$_stow" = "x" ]; then
        doit sudo $INSTALL stow
    fi
}

_install() {
    local _exe=$1

    local _path=$(which $_exe)

    if [ -e $_path ]
    then
        echo "[$_exe] exists at [$_path] -- not installing!"
    else
        doit sudo $INSTALL $_exe
    fi
}

link_file() {
    local _source=$1
    local _target=${2:- $HOME}

    if [ -e "$_target" ]
    then
        echo "[$_target] already exists! skipping"
    else
        echo "source: $_source ; target: $_target"
        doit ln -s $_source $_target
    fi
}

_stow() {
    local _source=$1
    local _target=${2:- $HOME}

    if [ -e "$_target/$_source" ]
    then
        echo "[$_target/$_source] already exists! skipping"
    else
        stow $_source --target $_target
    fi
}

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

_SYSTEM=$(getsystem)
INSTALL=$(setup)

doit git submodule update --init --recursive

echo "found install to be [$INSTALL]"

_install "stow"

install_sqlite
_install curl
_install vim
_install tmux

link_file $WORKDIR/i3/config "$HOME/.config/i3/config"
link_file $WORKDIR/vim/vim "$HOME/.vim"
link_file $WORKDIR/vim/vimrc "$HOME/.vimrc"
link_file $WORKDIR/stow/stowrc "$HOME/.stowrc"
link_file $WORKDIR/tmux/tmux.conf "$HOME/.tmux.conf"
link_file $WORKDIR/bash/bashrc "$HOME/.bashrc"
link_file $WORKDIR/bash/bash_aliases "$HOME/.bash_aliases"
link_file $WORKDIR/bash/bash_completion "$HOME/.bash_completion"
link_file $WORKDIR/bash/bash_completion.d "$HOME/.bash_completion.d"
link_file $WORKDIR/bash/bash_functions "$HOME/.bash_functions"
link_file $WORKDIR/bash/bash_functions.d "$HOME/.bash_functions.d"
link_file $WORKDIR/bash/dircolors "$HOME/.dircolors"
link_file $WORKDIR/X/Xdefaults "$HOME/.Xdefaults"
