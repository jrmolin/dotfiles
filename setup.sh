#!/bin/bash

set -e

DEBUG=1

# Colors (only if terminal supports them)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    DIM=''
    NC=''
fi

# Colored output helpers
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

header() {
    echo -e "\n${BOLD}${CYAN}==> $*${NC}"
}

WORKDIR=`dirname $0`
CWD=`pwd`
cd $WORKDIR
WORKDIR=`pwd`

arch() {
    echo "$(uname -m | sed 's/aarch/arm/')"
}

oops() {
    error "$0:" "$@"
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


setupzig() {
    require_util curl "download things, like for installing zig"
    local ver=0.11.0

    info "Installing ${BOLD}Zig${NC} v${ver}..."

    if [ -d /opt/zig ]
    then
        warn "Removing existing Zig installation..."
        sudo rm -rf /opt/zig
    fi

    sudo mkdir /opt/zig
    sudo chown $USER:$USER /opt/zig

    doit curl -fLo /tmp/zig.tar.xz https://ziglang.org/download/$ver/zig-linux-$(arch)-$ver.tar.xz

    doit tar xf /tmp/zig.tar.xz -C /opt/zig --strip-components=1
    success "Zig installed to ${CYAN}/opt/zig${NC}"
}

install_font() {
    local font=FiraCodeNerdFont-Regular.ttf
    local font_mono=FiraCodeNerdFontMono-Regular.ttf

    if [[ "${_SYSTEM}" == "macos" ]]; then
        # macOS: use Homebrew cask
        require_util brew "install fonts on macOS"

        # Check if font is already installed
        if [ -f "$HOME/Library/Fonts/$font" ] || brew list --cask font-fira-code-nerd-font &> /dev/null; then
            success "FiraCode Nerd Font already installed -- skipping"
        else
            info "Installing ${BOLD}FiraCode Nerd Font${NC} via Homebrew..."
            doit brew install --cask font-fira-code-nerd-font
            success "Font installed!"
        fi
    else
        # Linux: download and install manually
        require_util curl "download fonts"
        require_util unzip "extract font archive"

        local font_dir="$HOME/.local/share/fonts"

        if [ ! -f "$font_dir/$font" ]; then
            info "Installing ${BOLD}FiraCode Nerd Font${NC}..."

            local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
            local _file="firacode.zip"

            # Create font directory if needed
            mkdir -p "$font_dir"

            # Download and extract
            mkdir -p tmpfonts
            pushd . > /dev/null
            cd tmpfonts
            curl -Lo $_file $url
            unzip -q $_file
            mv $font "$font_dir/$font"
            mf $font_mono "$font_dir/$font_mono"
            popd > /dev/null
            rm -rf tmpfonts

            # Update font cache
            doit fc-cache -fv
            success "Font installed to ${CYAN}$font_dir${NC}"
        else
            success "FiraCode Nerd Font already installed -- skipping"
        fi
    fi
}

installvim() {
    if [[ "${_SYSTEM}" == "macos" ]]; then
        # macOS: use Homebrew
        require_util brew "install packages on macOS"

        if command -v nvim &> /dev/null; then
            success "Neovim already installed via brew -- skipping"
        else
            info "Installing ${BOLD}Neovim${NC} via Homebrew..."
            doit brew install neovim
            success "Neovim installed via Homebrew!"
        fi
    else
        # Linux: download binary based on architecture
        require_util curl "download neovim release"

        local destiny="/opt/nvim"
        local _arch=$(arch)

        if [ ! -d "$destiny/bin" ]; then
            info "Installing ${BOLD}Neovim${NC} for Linux (${_arch})..."

            local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${_arch}.tar.gz"
            local dl="nvim.tgz"

            # Download the release
            doit curl -Lo $dl $url

            # Create destination and extract
            doit sudo mkdir -pv $destiny
            doit sudo chown $USER:$USER $destiny
            doit tar xf $dl -C $destiny --strip-components=1

            # Cleanup
            doit unlink $dl
            success "Neovim installed to ${CYAN}$destiny${NC}"
        else
            success "Neovim already installed at ${CYAN}$destiny${NC} -- skipping"
        fi
    fi
}

setupvim() {
    require_util curl "download things, like for installing guix"

    if [ ! -f $HOME/.config/nvim/init.lua ]
    then
        info "Setting up ${BOLD}Neovim${NC} config..."
        doit mkdir -pv $HOME/.config/nvim
        doit ln -s $WORKDIR/nvim/init.lua $HOME/.config/nvim
    else
        success "Neovim config already exists -- skipping"
    fi

    if [ ! -e vim/vim/autoload/plug.vim ]
    then
        info "Installing ${BOLD}vim-plug${NC}..."
        doit curl -fLo vim/vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        success "vim-plug installed!"
    else
        success "vim-plug already installed -- skipping"
    fi
}

install_zig() {
    destiny=/opt/zig

    if [ ! -d $destiny ]
    then
        info "Installing ${BOLD}Zig${NC}..."
        local url="https://ziglang.org/download/0.11.0/zig-linux-$(arch)-0.11.0.tar.xz"
        local dl=zig.txz

        sudo mkdir $destiny
        sudo chown $USER:$USER $destiny
        doit curl -fLo $dl $url
        doit tar xf $dl -C $destiny --strip-components=1
        doit rm $dl
        success "Zig installed to ${CYAN}$destiny${NC}"
    else
        success "Zig already installed -- skipping"
    fi

}

doit() {
    if [ "x$DEBUG" = "x1" ]; then
        echo -e "${DIM}+ $*${NC}"
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
        success "curl exists at ${CYAN}$CURL${NC} -- skipping"
    else
        info "Installing curl..."
        doit sudo $INSTALL curl
    fi

}

_install() {
    local _exe=${2:-$1}

    local _path=$(type -p $_exe)

    if [[ -n $_path && -f "$_path" ]]
    then
        success "${BOLD}$_exe${NC} exists at ${CYAN}$_path${NC} -- skipping"
    else
        info "Installing ${BOLD}$1${NC}..."
        doit sudo $INSTALL $1
    fi
}

link_file() {
    local _source=$1
    local _target=${2:- $HOME}

    if [ -e "$_target" ]
    then
        warn "${CYAN}$_target${NC} already exists -- skipping"
    else
        info "Linking ${CYAN}$_source${NC} -> ${CYAN}$_target${NC}"
        doit ln -s $_source $_target
    fi
}

unlink_file() {
    local _target=$1

    if [ -e "$_target" ]
    then
        info "Unlinking ${CYAN}$_target${NC}"
        doit unlink $_target
    else
        warn "${CYAN}$_target${NC} does not exist -- skipping"
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
    header "Creating symlinks"
    if [[ "${_SYSTEM}" == "macos" ]] ; then
        link_file $WORKDIR/zsh/zshrc "$HOME/.zshrc"
        link_file $WORKDIR/zsh/zshenv "$HOME/.zshenv"
        link_file $WORKDIR/zsh/zprofile "$HOME/.zprofile"
    else
        error "Unsupported system for automatic linking!"
        exit
        #link_file $WORKDIR/i3/config "$HOME/.config/i3/config"
        #link_file $WORKDIR/i3/i3status.conf "$HOME/.i3status.conf"
        #link_file $WORKDIR/stow/stowrc "$HOME/.stowrc"
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
    fi
    link_file $WORKDIR/vim/vim "$HOME/.vim"
    link_file $WORKDIR/vim/vimrc "$HOME/.vimrc"
    link_file $WORKDIR/nvim "$HOME/.config/nvim"
    link_file $WORKDIR/tmux/tmux.conf "$HOME/.tmux.conf"
    link_file $WORKDIR/tmux/tmux "$HOME/.tmux"
}

undolinks() {
    header "Removing symlinks"
    if [[ "${_SYSTEM}" == "macos" ]] ; then
        unlink_file "$HOME/.zshrc"
        unlink_file "$HOME/.zshenv"
        unlink_file "$HOME/.zshprofile"
    else
        #unlink_file $WORKDIR/i3/config "$HOME/.config/i3/config"
        #unlink_file $WORKDIR/i3/i3status.conf "$HOME/.i3status.conf"
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
    fi
    unlink_file "$HOME/.vim"
    unlink_file "$HOME/.vimrc"
    unlink_file "$HOME/.tmux.conf"
    unlink_file "$HOME/.tmux"
}

install_rust() {
    if [ ! -d $HOME/.cargo ]
    then
        info "Installing ${BOLD}Rust${NC}..."
        doit curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        source $HOME/.cargo/env
        success "Rust installed!"
    else
        success "Rust already installed -- skipping"
    fi


}

install_starship() {
    if [ "xfile" != "x$(fnexists starship)" ]
    then
        info "Installing ${BOLD}Starship${NC}..."
        doit curl -sS https://starship.rs/install.sh | sh
        success "Starship installed!"
    else
        success "Starship already installed -- skipping"
    fi
}

runrun() {
    header "Installing dependencies"
    install_curl
    #install_zig
    install_font
    install_rust
    install_starship

    _install sqlite3
    _install vim
    setupvim
    _install tmux

    dolinks
}

if [ "x$1" = "x" ]
then
    echo -e "${BOLD}Usage:${NC} $0 ${CYAN}<command>${NC}"
    echo ""
    echo -e "${BOLD}Commands:${NC}"
    echo -e "  ${CYAN}install${NC}     Full installation (curl, fonts, rust, vim, tmux, links)"
    echo -e "  ${CYAN}installvim${NC}  Install and setup neovim"
    echo -e "  ${CYAN}vim${NC}         Setup vim configuration only"
    echo -e "  ${CYAN}zig${NC}         Install zig compiler"
    echo -e "  ${CYAN}links${NC}       Create dotfile symlinks"
    echo -e "  ${CYAN}unlink${NC}      Remove dotfile symlinks"
    echo -e "  ${CYAN}font${NC}        Install Nerd Fonts"
elif [ "x$1" = "xinstallvim" ]
then
    header "Installing Neovim"
    installvim
    if [[ "x$2" != "x--no-setup" ]] ; then
        setupvim
    fi
    success "Neovim installation complete!"
elif [ "x$1" = "xvim" ]
then
    header "Setting up Vim"
    setupvim
    success "Vim setup complete!"
elif [ "x$1" = "xzig" ]
then
    header "Installing Zig"
    setupzig
    success "Zig installation complete!"
elif [ "x$1" = "xlinks" ]
then
    dolinks
    success "Symlinks created!"
elif [ "x$1" = "xunlink" ]
then
    undolinks
    success "Symlinks removed!"
elif [ "x$1" = "xinstall" ]
then
    info "Package manager: ${BOLD}$INSTALL${NC}"
    runrun
    success "Installation complete!"
elif [ "x$1" = "xfont" ]
then
    header "Installing fonts"
    install_font
    success "Font installation complete!"
else
    warn "Running custom command: ${BOLD}$1${NC}"
    $1
fi
