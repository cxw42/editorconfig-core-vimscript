#!/bin/sh
# fetch-vim.bat: Fetch vim if necessary
# For use in the editorconfig-core-vimscript Appveyor build

set -x
uname -a
pwd
ls

# If it's already been loaded from the cache, we're done
if [ -x /vim/usr/bin/vim ]; then
    exit 0
fi

# Otherwise, download and unzip it.
appveyor DownloadFile https://github.com/vim/vim-appimage/releases/download/v8.1.0553/GVim-v8.1.0553-git07dc18ffa-glibc2.15.glibc2.15-x86_64.AppImage

rm -rf /vim

chmod u+x gvim.AppImage
./gvim.AppImage --appimage-extract
ls
mv squashfs-root /vim
echo Done
