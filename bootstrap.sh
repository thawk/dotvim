#!/bin/sh
vim_path=$(dirname $(readlink -f "$0"))

if [ ! -e ~/.vimrc.local ]
then
    cp "${vim_path}/vimrc.local.sample" ~/.vimrc.local
fi

if [ ! -e "${vim_path}/bundle/neobundle.vim/plugin/neobundle.vim" ]
then
    cd "${vim_path}"
    git submodule init
    git submodule update
fi

if [ -d "${vim_path}/bundle/vimproc_release" ]
then
    cd "${vim_path}/bundle/vimproc_release"
    find -name "*.so" -o -name "*.dll" | xargs --no-run-if-empty touch -t 200001010000.00
    make
    cd ${OLDPWD}
fi

if [ -d "${vim_path}/bundle/unicode.vim" ]
then
    if [ ! -f "${vim_path}/bundle/unicode.vim/autoload/unicode/UnicodeData.txt" ]
    then
        mkdir -p "${vim_path}/bundle/unicode.vim/autoload/unicode"
        cp "${vim_path}/UnicodeData.txt" "${vim_path}/bundle/unicode.vim/autoload/unicode/"
    fi
fi
