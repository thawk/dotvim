#!/bin/sh
vim_path=$(dirname $(readlink -f "$0"))

if [ ! -e ~/.vimrc ]
then
    echo "runtime vimrc" > ~/.vimrc
fi

if [ ! -e ~/.vimrc.local ]
then
    cp "${vim_path}/vimrc.local.sample" ~/.vimrc.local
fi

if [ -d "${vim_path}/bundle/vimproc" ]
then
    cd "${vim_path}/bundle/vimproc"
    find -name "*.so" -o -name "*.dll" | xargs --no-run-if-empty touch -t 200001010000.00
    case "$(uname -s)" in
        Darwin)
            make -f make_mac.mak
            ;;
        CYGWIN*)
            make -f make_cygwin.mak
            ;;
        MINGW32*)
            make -f make_mingw32.mak
            ;;
        MINGW64*)
            make -f make_mingw64.mak
            ;;
        Linux|MSYS*)
            make -f make_unix.mak
            ;;
        *)
            make -f make_unix.mak
            ;;
    esac
    cd ${OLDPWD}
fi
