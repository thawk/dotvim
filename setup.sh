#!/bin/sh
if [ ! -f ~/.vimrc ]
then
    echo 'runtime vimrc' > ~/.vimrc
fi

vim_path=$(dirname $(readlink -f "$0"))

if [ -d "${vim_path}/bundle/vimproc" ]
then
    cd "${vim_path}/bundle/vimproc"
    find -name "*.so" | xargs --no-run-if-empty touch -t 200001010000.00
    make -f make_unix.mak
    cd ${OLDPWD}
fi
