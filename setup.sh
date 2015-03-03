#!/bin/sh
if [ ! -f ~/.vimrc ]
then
    echo 'runtime vimrc' > ~/.vimrcq
fi

if [ -d ~/.vim/bundle/vimproc ]
then
    cd ~/.vim/bundle/vimproc
    make -f make_unix.mak
    touch -t 200001010000.00 autoload/vimproc_unix.so
    cd ${OLDPWD}
fi
