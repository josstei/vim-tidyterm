function! tidyterm#terminal#Hide() abort
    call tidyterm#terminal#Close()
    call tidyterm#buffer#Previous()
endfunction

function! tidyterm#terminal#Show() abort
    call tidyterm#buffer#Get() 
    if has('nvim')
        startinsert
    elseif &buftype ==# 'terminal' && mode() ==# 'n'
        call feedkeys("i", "n")
    endif
endfunction

function! tidyterm#terminal#Active() abort
    return g:term_winid != -1 && win_gotoid(g:term_winid) && &buftype ==# 'terminal'
endfunction

function! tidyterm#terminal#Close() abort
    close!
    let g:term_winid = -1
endfunction
