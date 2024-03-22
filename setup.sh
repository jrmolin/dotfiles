#!/bin/bash

set -e

DEBUG=1

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

oops() {
    echo "$0:" "$@" >&2
    exit 1
}

function fnexists()
{
    local result=$(LC_ALL=C type -t "$1")
    echo $result
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


install_font() {
    local font=FiraCodeNerdFont-Regular.ttf
    local destiny="$HOME/.fonts/$font"
    if [ ! -f $destiny ]
    then
        local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
        local _file="firacode.zip"
        mkdir -p tmpfonts
        pushd .
        cd tmpfonts
        curl -Lo $_file $url


        if [ ! -d $HOME/.fonts ]
        then
            mkdir $HOME/.fonts
        fi

        unzip -q $_file
        mv $font $destiny
        popd
        rm -rf tmpfonts
        fc-cache -fv
    fi

}

setupvim() {
    require_util curl "download things, like for installing guix"

    local destiny="/opt/nvim"

    if [ ! -d $destiny ]
    then

        local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
        local dl="nvim.tgz"

        # curl the thing
        doit curl -Lo $dl $url

        doit sudo mkdir $destiny
        doit sudo chown $USER:$USER $destiny

        # tar xf nvim.tgz -C $destiny --strip-components=1
        doit tar xf $dl -C $destiny --strip-components=1

        # remove the file
        doit unlink $dl
    fi

    if [ ! -f $HOME/.config/nvim/init.lua ]
    then
        doit mkdir -pv $HOME/.config/nvim
        doit ln -s $WORKDIR/nvim/init.lua $HOME/.config/nvim
    fi

    if [ ! -e vim/vim/autoload/plug.vim ]
    then
        doit curl -fLo vim/vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
}

install_zig() {
    destiny=/opt/zig

    if [ ! -d $destiny ]
    then
        local url="https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz"
        local dl=zig.txz

        sudo mkdir $destiny
        sudo chown $USER:$USER $destiny
        doit curl -fLo $dl $url
        doit tar xf $dl -C $destiny --strip-components=1
        doit rm $dl
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

    if [[ -n $_path && -f "$_path" ]]
    then
        echo "[$_exe] exists at [$_path] -- not installing!"
    else
        doit sudo $INSTALL $1
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

unlink_file() {
    local _target=$1

    if [ -e "$_target" ]
    then
        echo "target: $_target"
        doit unlink $_target
    fi
}

_SYSTEM=$(getsystem)
INSTALL=$(setup)

ensure_dir_exists () {
    if [ ! -d $1 ]
    then
        mkdir -pv $1
    fi
}

dolinks() {
    #link_file $WORKDIR/i3/config "$HOME/.config/i3/config"
    #link_file $WORKDIR/i3/i3status.conf "$HOME/.i3status.conf"
    link_file $WORKDIR/vim/vim "$HOME/.vim"
    link_file $WORKDIR/vim/vimrc "$HOME/.vimrc"
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
    ensure_dir_exists "$HOME/.emacs.d/"
    link_file $WORKDIR/emacs/Emacs.org "$HOME/.emacs.d/Emacs.org"
}

undolinks() {
    #unlink_file $WORKDIR/i3/config "$HOME/.config/i3/config"
    #unlink_file $WORKDIR/i3/i3status.conf "$HOME/.i3status.conf"
    unlink_file "$HOME/.vim"
    unlink_file "$HOME/.vimrc"
    unlink_file "$HOME/.tmux.conf"
    unlink_file "$HOME/.tmux"
    unlink_file "$HOME/.bashrc"
    unlink_file "$HOME/.bash_aliases"
    unlink_file "$HOME/.bash_completion"
    unlink_file "$HOME/.bash_completion.d"
    unlink_file "$HOME/.bash_functions"
    unlink_file "$HOME/.bash_functions.d"
    unlink_file "$HOME/.dircolors"
    #ensure_dir_exists "$HOME/.emacs.d/"
    unlink_file "$HOME/.emacs.d/Emacs.org"
    #unlink_file "$HOME/.Xresources"
    #unlink_file "$HOME/.direnvrc"
}

install_rust() {
    if [ ! -d $HOME/.cargo ]
    then
        doit curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
    fi


    if [ "xfile" != "x$(fnexists starship)" ]
    then
        doit curl -sS https://starship.rs/install.sh | sh
    fi
}

runrun() {
    install_curl
    install_zig
    install_font
    install_rust

    _install sqlite3
    _install vim
    setupvim
    _install tmux

    dolinks
}

if [ "x$1" = "x" ]
then
    echo "Usage: $0 <install|links|unlink>"
elif [ "x$1" = "xvim" ]
then
    setupvim
    echo "finished!"
elif [ "x$1" = "xlinks" ]
then
    dolinks
    echo "finished!"
elif [ "x$1" = "xunlink" ]
then
    undolinks
    echo "finished!"
elif [ "x$1" = "xinstall" ]
then
    echo "found install to be [$INSTALL]"
    runrun
    echo "finished!"
elif [ "x$1" = "xfont" ]
then
    install_font
    echo "finished!"
else
    echo "trying to run whatever you passed. danger!!"
    $1
fi
