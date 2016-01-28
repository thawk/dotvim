function! s:AsciidocEnableSyntaxRanges()
    " source block syntax highlighting
    if exists('g:loaded_SyntaxRange')
        for lang in ['c', 'python', 'vim', 'javascript', 'cucumber', 'xml', 'typescript', 'sh', 'java', 'cpp', 'haskell']
            if !empty(findfile("syntax/" . lang . ".vim", &runtimepath))
                call SyntaxRange#Include(
                            \  '\c\[source\s*,\s*' . lang . '.*\]\s*\n[=-]\{4,\}\n'
                            \, '\]\@<!\n[=-]\{4,\}\n'
                            \, lang, 'NonText')
            endif
        endfor
    endif
endfunction

call s:AsciidocEnableSyntaxRanges()

" 禁用对于双行标题的高亮，以免把windbg之类的输出当成双行标题
syn clear asciidocTwoLineTitle

" 各种block要求头尾长度一致
syn clear asciidocLiteralBlock
syn clear asciidocListingBlock
syn clear asciidocCommentBlock
syn clear asciidocPassthroughBlock

syn region asciidocLiteralBlock start=/^\z(\.\{4,}\)$/ end=/^\z1$/ contains=asciidocCallout,asciidocToDo keepend
syn region asciidocListingBlock start=/^\z(-\{4,}\)$/ end=/^\z1$/ contains=asciidocCallout,asciidocToDo keepend
syn region asciidocCommentBlock start="^\z(/\{4,}\)$" end="^/\z1$" contains=asciidocToDo
syn region asciidocPassthroughBlock start="^\z(+\{4,}\)$" end="^\z1$"
