function! tidyterm#terminal#Hide(terminal_name) abort
    let l:terminals = tidyterm#session#GetTerminals()
    if has_key(l:terminals, a:terminal_name)
        let l:buffer_info = l:terminals[a:terminal_name]
        call tidyterm#window#Close(a:terminal_name, l:buffer_info)
    endif
    call tidyterm#buffer#ToPrevious()
endfunction

function! tidyterm#terminal#Show(terminal_name) abort
    let l:terminals = tidyterm#session#GetTerminals()
    let l:buffer_info = get(l:terminals, a:terminal_name, {})
    
    let l:winid = tidyterm#window#Open(a:terminal_name, l:buffer_info)
    
    if !has_key(l:buffer_info, 'bufnr') || !bufexists(l:buffer_info['bufnr'])
        call tidyterm#buffer#CallTerminal()
        let l:buffer_info['bufnr'] = bufnr('%')
        call tidyterm#session#AddTerminal(a:terminal_name, l:buffer_info)
    endif
    
    call tidyterm#window#Focus(a:terminal_name, l:buffer_info)
endfunction

function! tidyterm#terminal#Active(terminal_name) abort
    let l:terminals = tidyterm#session#GetTerminals()
    if !has_key(l:terminals, a:terminal_name)
        return 0
    endif
    
    let l:buffer_info = l:terminals[a:terminal_name]
    return tidyterm#window#IsActive(a:terminal_name, l:buffer_info)
endfunction

function! tidyterm#terminal#Close(terminal_name) abort
    let l:terminals = tidyterm#session#GetTerminals()
    if has_key(l:terminals, a:terminal_name)
        let l:buffer_info = l:terminals[a:terminal_name]
        call tidyterm#window#Close(a:terminal_name, l:buffer_info)
    endif
endfunction
