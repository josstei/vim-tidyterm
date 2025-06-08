function! tidyterm#buffer#Get() abort
    let g:prev_winid = win_getid()
    if !bufexists(g:term_bufnr) || !buflisted(g:term_bufnr)
        botright terminal
        let g:term_bufnr = bufnr('%')
    else
        botright split
        execute 'buffer' g:term_bufnr
    endif
    resize 15
    let g:term_winid = win_getid()
endfunction

function! tidyterm#buffer#Previous() abort
    if win_gotoid(g:prev_winid) == 0 | wincmd p | endif
endfunction
