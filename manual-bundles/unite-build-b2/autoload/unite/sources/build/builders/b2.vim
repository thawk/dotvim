"=============================================================================
" FILE: b2.vim
" AUTHOR:  T.Hawk <thawk009 at gmail.com>
" Last Modified: 31 Jul 2012.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

" Variables  "{{{
call unite#util#set_default('g:unite_builder_b2_command', 'b2')
"}}}

function! unite#sources#build#builders#b2#define() "{{{
  return executable(g:unite_builder_b2_command) ?
        \ s:builder : []
endfunction "}}}

let s:builder = {
      \ 'name': 'b2',
      \ 'description': 'Boost.Build builder',
      \ }

function! s:builder.detect(args, context) "{{{
    return findfile("Jamfile", ";") != ""
                \|| findfile("Jamroot", ";") != ""
                \|| findfile("Jamfile.v2", ";") != ""
                \|| findfile("Jamroot.v2", ";") != ""
endfunction"}}}

function! s:builder.initialize(args, context) "{{{
  return g:unite_builder_b2_command . ' ' . join(a:args)
endfunction"}}}

function! s:builder.parse(string, context) "{{{
    let re_ignore = '^warning: .*'
    let re1 = '^\(\f\+\):\(\d\+\):\(\d\+\): \(error\|warning\):.*'
    let re2 = '^\(\f\+\):\(\d\+\): \(error\|warning\):.*'
    if a:string =~ re_ignore
        return {}
    elseif a:string =~ re1
        return {
                    \'type' : substitute(a:string, re1, '\=submatch(4)', ''),
                    \'filename' : substitute(a:string, re1, '\=submatch(1)', ''),
                    \'line' : substitute(a:string, re1, '\=submatch(2)', ''),
                    \'col' : substitute(a:string, re1, '\=submatch(3)', ''),
                    \'text' : a:string }
    elseif a:string =~ re2
        return {
                    \'type' : substitute(a:string, re2, '\=submatch(3)', ''),
                    \'filename' : substitute(a:string, re2, '\=submatch(1)', ''),
                    \'line' : substitute(a:string, re2, '\=submatch(2)', ''),
                    \'text' : a:string }
    elseif a:context.source__builder_is_bang
        return { 'type' : 'message', 'text' : a:string }
    elseif a:string =~ '^\.\.\..*\.\.\.\s*$'
        return { 'type' : 'message', 'text' : a:string }
    elseif a:string =~ '^\*\*\w\+\*\*'                      " Boost.Test result
        return { 'type' : 'message', 'text' : a:string }
    elseif a:string =~ '^\(\f\+\):'                         " File context
        return { 'type' : 'message', 'text' : a:string }
    else
        return {}
    endif
endif
endfunction "}}}

" vim: foldmethod=marker
