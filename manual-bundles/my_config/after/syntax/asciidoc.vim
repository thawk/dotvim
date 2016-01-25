function! s:AsciidocEnableSyntaxRanges()
    " source block syntax highlighting
    if exists('g:loaded_SyntaxRange')
        for lang in ['c', 'python', 'vim', 'javascript', 'cucumber', 'xml', 'typescript', 'sh', 'java', 'cpp']
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
syn match asciidocTwoLineTitle /^!!!Non Matchable!!!$/
