function! s:MarkdownEnableSyntaxRanges()
    " source block syntax highlighting
    if exists('g:loaded_SyntaxRange')
        for lang in g:my_sub_syntaxes
            call SyntaxRange#Include(
                        \ '^```' . lang . '$'
                        \, '^```$'
                        \, lang, 'NonText')
        endfor
    endif
endfunction

call s:MarkdownEnableSyntaxRanges()

