function! s:MarkdownEnableSyntaxRanges()
    " source block syntax highlighting
    if exists('g:loaded_SyntaxRange')
        for lang in ['c', 'python', 'vim', 'javascript', 'cucumber', 'xml', 'typescript', 'sh', 'java', 'cpp']
            if !empty(findfile("syntax/" . lang . ".vim", &runtimepath))
                call SyntaxRange#Include(
                            \ '^```' . lang . '$'
                            \, '^```$'
                            \, lang, 'NonText')
            endif
        endfor
    endif
endfunction

call s:MarkdownEnableSyntaxRanges()

