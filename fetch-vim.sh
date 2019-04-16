#!/bin/bash
# fetch-vim.bat: Fetch vim if necessary
# For use in the editorconfig-core-vimscript Appveyor build

# Debugging
set -x
set -o nounset
#set -o errexit

# Basic system info
uname -a
pwd
ls -l

echo "VIM_EXE: $VIM_EXE"
set

# If it's already been loaded from the cache, we're done
if [[ -x "$VIM_EXE" ]]; then
    echo Vim found in cache at "$VIM_EXE"
    exit 0
fi

## Note: this gives me an "exec format error".
## Otherwise, download and unzip it.
#DL='GVim-v8.1.0553-git07dc18ffa-glibc2.15.glibc2.15-x86_64.AppImage'
#rm -f "$DL"
#appveyor DownloadFile "https://github.com/vim/vim-appimage/releases/download/v8.1.0553/$DL"
#
WHITHER="$APPVEYOR_BUILD_FOLDER/vim"
#7z x "$DL" -o"$WHITHER"
#chmod a+x vim/usr/bin/* vim/usr/lib/* vim/usr/lib/x86_64-linux-gnu/*
#chmod a+x vim/usr/share/vim/vim81/tools/*

git clone https://github.com/vim/vim-appimage.git
cd vim-appimage
git submodule update --init --recursive

cd vim/src
./configure --with-features=huge --prefix="$WHITHER" --enable-fail-if-missing
make -j2    # Free tier provides two cores
make install
./vim --version
cd $APPVEYOR_BUILD_FOLDER
find . -type f -name vim -exec ls -l {} +

# Status
#ls -lR || true
echo Done fetching and installing vim
