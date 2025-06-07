if exists('g:tidyterm_loaded')
    finish
endif

let g:tidyterm_loaded   = 1
let g:term_bufnr        = -1
let g:term_winid        = -1
let g:prev_winid        = -1

command! TidyTerm call TidyTermToggle()

function! TidyTermToggle() abort
    try
        call TidyTermCompatible()
        call tidyterm#Toggle()
    catch /*./
        echom 'TidyTerm: ' . v:exception
    endtry
endfunction

function! TidyTermCompatible() abort
    if !exists(':terminal') | throw "Terminal Command not supported" | endif
endfunction
