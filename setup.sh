#!/bin/bash

set -e

DEBUG=1

oops() {
    echo "$0:" "$@" >&2
    exit 1
}

require_util() {
    type "$1" > /dev/null 2>&1 || command -v "$1" > /dev/null 2>&1 |
        oops "don't have '$1' installed, which we need to $2"
}

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
    elif [ "x$_SYSTEM" = "xcentos" ]
    then
        INSTALL="yum install -y"
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


setupvim() {
    require_util curl "download things, like for installing nix"

    if [ ! -e vim/vim/autoload/plug.vim ]
    then
        doit curl -fLo vim/vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
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

# install curl
install_curl() {
    local CURL=$(type -p curl)

    if [ -e "$CURL" ]
    then
        echo "[curl] exists at [$CURL] -- not installing!"
    else
        doit sudo $INSTALL curl
    fi

}

_install() {
    local _exe=${2:-$1}

    local _path=$(type -p $_exe)

    if [ -f $_path ]
    then
        echo "[$_exe] exists at [$_path] -- not installing!"
    else
        doit nix-env -i $1
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

install_nix() {
    url="https://nixos.org/nix/install"

    if [ "file" = $(type -t nix) ]
    then
        echo "[$(type -p nix)] already exists! skipping"
        return
    fi

    require_util curl "download things, like for installing nix"
    res=$(curl -L $url | sh)
    echo $res

}

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

_SYSTEM=$(getsystem)
INSTALL=$(setup)

dolinks() {
    #link_file $WORKDIR/i3/config "$HOME/.config/i3/config"
    #link_file $WORKDIR/i3/i3status.conf "$HOME/.i3status.conf"
    link_file $WORKDIR/vim/vim "$HOME/.vim"
    link_file $WORKDIR/vim/vimrc "$HOME/.vimrc"
    #link_file $WORKDIR/stow/stowrc "$HOME/.stowrc"
    link_file $WORKDIR/tmux/tmux.conf "$HOME/.tmux.conf"
    link_file $WORKDIR/tmux/tmux "$HOME/.tmux"
    link_file $WORKDIR/bash/bashrc "$HOME/.bashrc"
    link_file $WORKDIR/bash/bash_aliases "$HOME/.bash_aliases"
    link_file $WORKDIR/bash/bash_completion "$HOME/.bash_completion"
    link_file $WORKDIR/bash/bash_completion.d "$HOME/.bash_completion.d"
    link_file $WORKDIR/bash/bash_functions "$HOME/.bash_functions"
    link_file $WORKDIR/bash/bash_functions.d "$HOME/.bash_functions.d"
    link_file $WORKDIR/bash/dircolors.nord "$HOME/.dircolors"
    #link_file $WORKDIR/X/Xresources "$HOME/.Xresources"
#    link_file $WORKDIR/direnv/direnvrc "$HOME/.direnvrc"
}

runrun() {
    install_curl
    install_nix
    _install glibc-locales
    _install stow

    _install sqlite3
    _install vim
    setupvim
    _install tmux

    dolinks
}

if [ "x$1" = "x" ]
then
    echo "Usage: $0 <install|links|nix>"
elif [ "x$1" = "xvim" ]
then
    setupvim
    echo "finished!"
elif [ "x$1" = "xnix" ]
then
    echo "found install to be [$INSTALL]"
    install_nix
    echo "finished!"
elif [ "x$1" = "xlinks" ]
then
    echo "found install to be [$INSTALL]"
    dolinks
    echo "finished!"
elif [ "x$1" = "xinstall" ]
then
    echo "found install to be [$INSTALL]"
    runrun
    echo "finished!"
else
    echo "trying to run whatever you passed. danger!!"
    $1
fi
