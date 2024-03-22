#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

use IO::Uncompress::Unzip qw( unzip $UnzipError );
use Cwd qw( abs_path );
use File::Basename qw( dirname );
use File::Path qw( make_path remove_tree );
use File::Copy qw( move );

use LWP::Simple;

my $here = dirname(abs_path($0));

say $here;

sub install_font {
    my $url = 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip';
    my $file = 'firacode.zip';
    my $font = 'FiraCodeNerdFont-Regular.ttf';
    my $destiny = "$ENV{HOME}/.fonts/$font";

    if (-f $destiny) {
        return;
    }

    my $tempdir = 'tmpfonts';
    mkdir($tempdir, 0700) unless(-d $tempdir);
    chdir($tempdir) or die "can't chdir to $tempdir\n";

    getstore($url, $file);

    unzip $file => $font, Name => $font
        or die "unzip failed: $UnzipError\n";

    make_path(dirname($destiny));

    move($font, $destiny);

    chdir($here);
    remove_tree($tempdir);

    system("fc-cache -f");
}

sub install_nvim() {
    my $destiny = "/opt/nvim";

    if (-d $destiny) {
        return;
    }

    my $url = "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz";
    my $dl = "nvim.tgz";

    # curl the thing
    getstore($url, $dl);

    system "sudo mkdir $destiny";
    system "sudo chown $ENV{USER}:$ENV{USER} $destiny";

    # tar xf nvim.tgz -C $destiny --strip-components=1
    system "tar xf $dl -C $destiny --strip-components=1"; 

    # remove the file
    unlink($dl);
}

sub install_tmux() {
    system "sudo apt install tmux";
}

install_font();
install_nvim();
install_tmux();
