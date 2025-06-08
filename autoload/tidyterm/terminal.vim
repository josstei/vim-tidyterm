function! tidyterm#terminal#Hide() abort
    call tidyterm#terminal#Close()
    call tidyterm#buffer#Previous()
endfunction

function! tidyterm#terminal#Show() abort
    let g:prev_winid = win_getid()
    call tidyterm#buffer#Get() 
    let g:term_winid = win_getid()
    startinsert
endfunction

function! tidyterm#terminal#Active() abort
    return g:term_winid != -1 && win_gotoid(g:term_winid) && &buftype ==# 'terminal'
endfunction

function! tidyterm#terminal#Close() abort
    close!
    let g:term_winid = -1
endfunction
