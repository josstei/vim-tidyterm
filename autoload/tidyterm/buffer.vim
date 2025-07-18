function! tidyterm#buffer#Commands() abort
    let l:position_map = tidyterm#config#GetPositionMap()
    let s:cmd_position = l:position_map['position']
    let s:cmd_resize = l:position_map['resize']
    let s:cmd_split = l:position_map['split']
    let s:cmd_size = l:position_map['size']
endfunction

function! tidyterm#buffer#ToPrevious() abort
    if exists('g:prev_winid') && win_gotoid(g:prev_winid) == 0 | wincmd p | endif
endfunction

function! tidyterm#buffer#ToCurrent(bufnr) abort
    execute 'buffer' a:bufnr
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
    
    call tidyterm#buffer#SetFiletype()
    
    if tidyterm#config#Get('auto_cd')
        let l:project_root = tidyterm#session#GetProjectRoot()
        if isdirectory(l:project_root)
            if has('nvim')
                call chansend(bufnr('%'), 'cd ' . shellescape(l:project_root) . "\n")
            else
                call term_sendkeys(bufnr('%'), 'cd ' . shellescape(l:project_root) . "\n")
            endif
        endif
    endif
endfunction

function! tidyterm#buffer#SetFiletype() abort
    let l:filetype = tidyterm#config#Get('filetype')
    if !empty(l:filetype)
        execute 'setlocal filetype=' . l:filetype
    endif
endfunction

function! tidyterm#buffer#Get(terminal_name) abort
    let g:prev_winid = win_getid()
    call tidyterm#buffer#Commands()
    
    let l:terminals = tidyterm#session#GetTerminals()
    let l:buffer_info = get(l:terminals, a:terminal_name, {})
    
    if !has_key(l:buffer_info, 'bufnr') || !bufexists(l:buffer_info['bufnr']) || !buflisted(l:buffer_info['bufnr'])
        call tidyterm#buffer#Open()
        call tidyterm#buffer#CallTerminal()
        let l:buffer_info['bufnr'] = bufnr('%')
    else
        call tidyterm#buffer#Open()
        call tidyterm#buffer#ToCurrent(l:buffer_info['bufnr'])
    endif

    call tidyterm#buffer#Resize()
    let l:buffer_info['winid'] = win_getid()
    
    call tidyterm#session#AddTerminal(a:terminal_name, l:buffer_info)
    
    return l:buffer_info
endfunction

