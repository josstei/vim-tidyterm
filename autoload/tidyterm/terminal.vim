function! tidyterm#terminal#Hide() abort
    call feedkeys("\<C-\\>\<C-n>", 'n')
    redraw
    if has('nvim')
        if exists('*term_getjob') && exists('*jobstop')
            let job = term_getjob(bufnr('%'))
            if job != v:null
                call jobstop(job)
            endif
        endif
    endif
    call tidyterm#terminal#Close()
    call tidyterm#buffer#Previous()
endfunction

function! tidyterm#terminal#Close() abort
    wincmd c
    let g:term_winid = -1
endfunction

function! tidyterm#terminal#Show() abort
    let g:prev_winid = win_getid()
    if tidyterm#buffer#Get() != 1
        call tidyterm#buffer#Focus() 
    endif
    let g:term_winid = win_getid()
    startinsert
endfunction

function! tidyterm#terminal#Active() abort
    return g:term_winid != -1 && win_gotoid(g:term_winid) && &buftype ==# 'terminal'
endfunction
