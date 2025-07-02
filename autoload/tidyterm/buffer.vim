let s:tidyterm_map = {
    \     'left': {
    \       'split'     : 'vsplit',
    \       'position'  : 'topleft',
    \       'resize'    : 'vertical resize',
    \       'size'      : 50 
    \     },
    \     'right': {
    \       'split'     : 'vsplit',
    \       'position'  : 'botright',
    \       'resize'    : 'vertical resize',
    \       'size'      : 50 
    \     },
    \     'top': {
    \       'split'     : 'split',
    \       'position'  : 'topleft',
    \       'resize'    : 'resize',
    \       'size'      : 15 
    \     },
    \     'bottom': {
    \       'split'     : 'split',
    \       'position'  : 'botright',
    \       'resize'    : 'resize',
    \       'size'      : 15 
    \     }
    \ }

function! tidyterm#buffer#Commands() abort
    let s:cmd_side      = get(g:, 'tidyterm_position', 'bottom')
    let l:cmd_map       = copy(s:tidyterm_map[s:cmd_side])
    let s:cmd_position  = get(l:cmd_map,'position','botright')   
    let s:cmd_resize    = get(l:cmd_map,'resize','resize')   
    let s:cmd_split     = get(l:cmd_map,'split','split')   
    let s:cmd_size      = get(l:cmd_map,'size',15)   
    let s:cmd_size      = get(g:, 'tidyterm_size',s:cmd_size)
endfunction

function! tidyterm#buffer#ToPrevious() abort
    if win_gotoid(g:prev_winid) == 0 | wincmd p | endif
endfunction

function! tidyterm#buffer#ToCurrent() abort
    execute 'buffer' g:term_bufnr
endfunction

function! tidyterm#buffer#Resize() abort
    execute s:cmd_resize . ' ' . s:cmd_size
endfunction

function! tidyterm#buffer#Open() abort
    execute s:cmd_position . ' ' . s:cmd_split
endfunction

function! tidyterm#buffer#CallTerminal() abort
    if has('nvim')
        terminal
    else
        call term_start(&shell, {'curwin': v:true})
    endif
    let g:term_bufnr = bufnr('%')
    call tidyterm#buffer#SetFiletype()
endfunction

function! tidyterm#buffer#SetFiletype() abort
    if exists('g:tidyterm_filetype') && !empty(g:tidyterm_filetype)
        execute 'setlocal filetype=' . g:tidyterm_filetype
    endif
endfunction

function! tidyterm#buffer#Get() abort
    let g:prev_winid = win_getid()
    call tidyterm#buffer#Commands()

    if !bufexists(g:term_bufnr) || !buflisted(g:term_bufnr)
        call tidyterm#buffer#Open()
        call tidyterm#buffer#CallTerminal()
    else
        call tidyterm#buffer#Open()
        call tidyterm#buffer#ToCurrent()
    endif

    call tidyterm#buffer#Resize()
    let g:term_winid = win_getid()
endfunction

