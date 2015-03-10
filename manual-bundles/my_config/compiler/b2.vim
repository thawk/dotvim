" Vim compiler file
" Compiler:         Boost Build

if exists("current_compiler")
  finish
endif
let current_compiler = "b2"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet errorformat&
CompilerSet errorformat+=%*[^\"]\"%f\"%*\\D%l:%c:\ %m
" CompilerSet errorformat+=%*[^\"]\"%f\"%*\\D%l:\ %m
CompilerSet errorformat+=\"%f\"%*\\D%l:%c:\ %m
" CompilerSet errorformat+=\"%f\"%*\\D%l:\ %m
CompilerSet errorformat+=%-G%f:%l:\ %trror:\ (Each\ undeclared\ identifier\ is\ reported\ only\ once
CompilerSet errorformat+=%-G%f:%l:\ %trror:\ for\ each\ function\ it\ appears\ in.)
CompilerSet errorformat+=%f:%l:%c:\ %trror:\ %m
CompilerSet errorformat+=%f:%l:%c:\ %tarning:\ %m
CompilerSet errorformat+=%f:%l:%c:\ %m
CompilerSet errorformat+=%f:%l:\ %trror:\ %m
CompilerSet errorformat+=%f:%l:\ %tarning:\ %m
CompilerSet errorformat+=%f:%l:\ %m
CompilerSet errorformat+=\"%f\"\\,\ line\ %l%*\\D%c%*[^\ ]\ %m
" CompilerSet errorformat+=%D%*\\a[%*\\d]:\ Entering\ directory\ `%f'
" CompilerSet errorformat+=%X%*\\a[%*\\d]:\ Leaving\ directory\ `%f'
" CompilerSet errorformat+=%D%*\\a:\ Entering\ directory\ `%f'
" CompilerSet errorformat+=%X%*\\a:\ Leaving\ directory\ `%f'
" CompilerSet errorformat+=%DMaking\ %*\\a\ in\ %f

" Doxygen的出错信息
CompilerSet errorformat+=Generating\ code\ for\ file\ %f:%l:%m
CompilerSet errorformat+=Generating\ docs\ for\ compound\ %f:%l:%m
CompilerSet errorformat+=Generating\ docs\ Error:\ %f:%l:%m
CompilerSet errorformat+=Generating\ annotated\ compound\ ind%f:%l:%m
CompilerSet errorformat+=Generating\ docs\ %f:%l:%m
CompilerSet errorformat+=Generating\ docs\ for\ page\ %\\w%\\+...%f:%l:%m
CompilerSet errorformat+=Generating\ Error:\ %f:%l:\ %m
CompilerSet errorformat+=Error:\ %f:%l:\ %m
CompilerSet errorformat^=Parsing\ file\ %f:%l:%m

" Boost.Assert: common-test_stream_reader: include/common/stream_reader.h:306:...
CompilerSet errorformat^=%[a-zA-Z0-9_-]%\\+:\ %f:%l:%m

" 忽略2012-01-18 13:14:15之类的日志行
CompilerSet errorformat^=%+G20%\[0-9]%\[0-9]-%\[0-9]%\[0-9]-%\[0-9]%\[0-9]\ %\[0-9]%\[0-9]:%\[0-9]%\[0-9]:%\[0-9]%\[0-9]%m

" xgettext出错信息
CompilerSet errorformat+=xgettext:\ %m\ at\ %f:%l.

CompilerSet makeprg=b2

if exists('g:compiler_b2_ignore_unmatched_lines')
  CompilerSet errorformat+=%-G%.%#
endif

let &cpo = s:cpo_save
unlet s:cpo_save
