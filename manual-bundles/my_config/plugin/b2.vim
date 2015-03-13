if &cp || exists('loaded_b2_compiler')
    finish
endif
let loaded_b2_compiler = 1

let s:save_cpo = &cpo
set cpo&vim

function s:InsideBoostBuildProj()
    for l:name in ["Jamfile", "Jamfile.v2", "Jamfile.jam", "Jamroot", "Jamroot.v2", "Jamroot.jam"]
        for l:p in findfile(l:name, ".;", -1)
            return 1
        endfor
    endfor

    return 0
endfunction

augroup b2_compiler_detect
    " 如果在Boost.Build项目中，则把编译器改为b2
    au!
    au VimEnter,BufNewFile,BufReadPost * if &makeprg=='make' && s:InsideBoostBuildProj() | compiler=b2 | endif
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" vi: ft=vim:tw=72:ts=4:fo=w2croql
