" We want to keep comments within a column limit, but not code.
" These two options give us that
setlocal formatoptions+=c   " Auto-wrap comments using textwidth
setlocal formatoptions+=r   " Automatically insert the current comment leader after hitting
                            " <Enter> in Insert mode.
setlocal formatoptions+=q   " Allow formatting of comments with "gq".
setlocal formatoptions-=t   " Do no auto-wrap text using textwidth (does not apply to comments)

setlocal textwidth=90

" This makes doxygen comments work the same as regular comments
setlocal comments-=://
setlocal comments+=:///,://

" " Indents are 4 spaces
" setlocal shiftwidth=4
" setlocal tabstop=4
" setlocal softtabstop=4
"
" " And they really are spaces, *not* tabs
" setlocal expandtab

" Setup for indending
" setlocal nosmartindent
" setlocal autoindent
" setlocal cindent
setlocal cinkeys-=0#
" 缩进设置。下面的s代表一个shiftwidth
setlocal cinoptions=
setlocal cinoptions+=^      " no specific indent for function
setlocal cinoptions+=:0     " case label indent
setlocal cinoptions+=l1     " align with a case label
setlocal cinoptions+=g0     " c++ scope declaration not indent
setlocal cinoptions+=ps     " K&R-style parameter declaration indent
setlocal cinoptions+=t0     " function return type declaration indent
setlocal cinoptions+=i2     " C++ base class declarations and constructor initializations
setlocal cinoptions+=+s     " continuation line indent
setlocal cinoptions+=c3     " comment line indent
setlocal cinoptions+=(0     " align to first non-white character after the unclosed parentheses
setlocal cinoptions+=us     " same as (N, but for one level deeper
setlocal cinoptions+=U0     " do not ignore the indenting specified by ( or u in case that the unclosed parentheses is the first non-white charactoer in its line
setlocal cinoptions+=w1
setlocal cinoptions+=Ws     " indent line ended with open parentheses

setlocal list

" Highlight strings inside C comments。c.vim中使用
let c_comment_strings=1

" Load up the doxygen syntax。doxygen.vim中使用
let g:load_doxygen_syntax=1

" The syntax highlight we use for the above error highlighting is 'BadInLine'
" and we set what that colour is right here.
"
" It's easier just to use black :)
"hi BadInLine gui=inverse term=inverse cterm=inverse
hi BadInLine gui=underline term=underline cterm=underline

" Enable/Disable the highlighting of tabs and of line length overruns
"nmap <silent> ,ee :call EnableErrorHighlights()<CR>
"nmap <silent> ,ed :call DisableErrorHighlights()<CR>

" " set up retabbing on a source file
" nmap <silent> ,rr :1,$retab<CR>

setlocal indentexpr=GoogleCppIndent()

if finddir("tags", &runtimepath) != ""
    let tags_dir = fnamemodify(finddir("tags", &runtimepath), ":p")
    let s:global_tags = split(glob(tags_dir . "*.tags"), "\n")
    if len(s:global_tags) > 0
        au FileType c,cpp let &l:tags=join([&tags] + s:global_tags, ",")
    endif
endif

" from https://github.com/vim-scripts/google.vim
function! GoogleCppIndent()
    let l:cline_num = line('.')

    let l:orig_indent = cindent(l:cline_num)

    if l:orig_indent == 0 | return 0 | endif

    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    if l:pline =~# '^\s*template' | return l:pline_indent | endif

    " TODO: I don't know to correct it:
    " namespace test {
    " void
    " ....<-- invalid cindent pos
    "
    " void test() {
    " }
    "
    " void
    " <-- cindent pos
    if l:orig_indent != &shiftwidth | return l:orig_indent | endif

    let l:in_comment = 0
    let l:pline_num = prevnonblank(l:cline_num - 1)
    while l:pline_num > -1
        let l:pline = getline(l:pline_num)
        let l:pline_indent = indent(l:pline_num)

        if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
            let l:in_comment = 1
        elseif l:in_comment == 1
            if l:pline =~ '/\*\(.\{-}\*/\)\@!'
                let l:in_comment = 0
            endif
        elseif l:pline_indent == 0
            if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
                if l:pline =~# '^\s*namespace.*'
                    return 0
                else
                    return l:orig_indent
                endif
            elseif l:pline =~# '\\$'
                return l:orig_indent
            endif
        else
            return l:orig_indent
        endif

        let l:pline_num = prevnonblank(l:pline_num - 1)
    endwhile

    return l:orig_indent
endfunction

function! OpenCProject()
    if has("cscope")
        let db = findfile("cscope.out", ";")
        if (!empty(db))
            let path = strpart(db, 0, match(db, "/cscope.out$"))
            set nocscopeverbose " suppress 'duplicate connection' error
            exe "cs add " . db . " " . path
            set cscopeverbose
        endif
    endif

    if &makeprg == 'make'
        if     findfile("Jamfile", ";") != "" ||
                    \findfile("Jamroot", ";") != "" ||
                    \findfile("Jamfile.v2", ";") != "" ||
                    \findfile("Jamroot.v2", ";") != ""
            "set makeprg=bjam
            set makeprg=b2
        endif
    endif
endfunction

" function! WhatFunctionAreWeIn()
"   let strList = ["while", "foreach", "ifelse", "if else", "for", "if", "else", "try", "catch", "case", "switch", "do"]
"   let foundcontrol = 1
"   let position = ""
"   let pos=getpos(".")          " This saves the cursor position
"   let view=winsaveview()       " This saves the window view
"   while (foundcontrol)
"     let foundcontrol = 0
"     normal [{
"     call search('\S','bW')
"     let tempchar = getline(".")[col(".") - 1]
"     if (match(tempchar, ")") >=0 )
"       normal %
"       call search('\S','bW')
"     endif
"     let tempstring = getline(".")
"     for item in strList
"       if( match(tempstring,item) >= 0 )
"         let position = item . " - " . position
"         let foundcontrol = 1
"         break
"       endif
"     endfor
"     if(foundcontrol == 0)
"       call cursor(pos)
"       call winrestview(view)
"       return tempstring.position
"     endif
"   endwhile
"   call cursor(pos)
"   call winrestview(view)
"   return tempstring.position
" endfunction

inoremap  <buffer>  /**<CR>     /**<CR><CR>/<Esc>kA<Space>@brief<Space>
inoremap  <buffer>  /**<        /**<<Space>@brief<Space><Space>*/<Left><Left><Left>
vnoremap  <buffer>  /**<        /**<<Space>@brief<Space><Space>*/<Left><Left><Left>
inoremap  <buffer>  ///<        ///<<Space>
vnoremap  <buffer>  ///<        ///<<Space>
inoremap  <buffer>  /**<Space>  /**<Space>@brief<Space><Space>*/<Left><Left><Left>
vnoremap  <buffer>  /**<Space>  /**<Space>@brief<Space><Space>*/<Left><Left><Left>

" nnoremap ff :<C-U>echo WhatFunctionAreWeIn()<CR>

setlocal foldmethod=syntax
setlocal keywordprg=man\ -S2:3
setlocal include=^\\s*#\\s*include\ \\(<boost/\\(fusion\\\\|\preprocesser\\\\|mpl\\\\|typeof[^>]\\\\|[^>]*/\\(detail\\\\|impl\\\\|platform\\\\|aux_\\)\\)\\)\\@!

call OpenCProject()

augroup local_ftplugin_cpp
    au!
    " Enable and disable the highlighting of lines greater than
    " our 'allowed' length
    if version < 703
        " au BufWinEnter *.h,*.cpp call EnableErrorHighlights()
        " au BufWinLeave *.h,*.cpp call DisableErrorHighlights()
        au BufWinEnter *.h,*.cpp let w:m1=matchadd('Search', '\%<92v.\%>91v', -1)
        au BufWinEnter *.h,*.cpp let w:m2=matchadd('ErrorMsg', '\%<121v.\%>120v', -1)
    else
        setlocal colorcolumn=+1,120
    endif

    " Change the directory when entering a buffer
    "au BufWinEnter,BufEnter *.h,*.cpp :lcd %:h

    " Recognize standard C++ headers
    au BufEnter /usr/include/c++/*          setf cpp
    au BufEnter /usr/include/g++-3/*        setf cpp

    au! BufNewFile *.h,*.c,*.cpp    set fenc=utf8 ff=dos " C/C++文件缺省为gbk编码


    " Setting for files following the GNU coding standard
    au BufEnter /usr/*                  setlocal
                \ cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
                \ shiftwidth=2
                \ tabstop=8
augroup END

" "}}}
