function! tidyterm#buffer#Create() abort
    if has('nvim')
        botright 15split
        terminal
    else
        botright terminal
        resize 15
    endif
endfunction

function! tidyterm#buffer#Focus() abort
    if has('nvim') | botright 15split | endif | execute 'buffer' g:term_bufnr
endfunction

function! tidyterm#buffer#Previous() abort
    if win_gotoid(g:prev_winid) == 0 | wincmd p | endif
endfunction

function! tidyterm#buffer#Get() abort
    if !bufexists(g:term_bufnr) || !buflisted(g:term_bufnr)
        call tidyterm#buffer#Create()
        let g:term_bufnr = bufnr('%')
        return 1
    endif
endfunction

