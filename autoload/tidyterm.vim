function! tidyterm#Init() abort
    call tidyterm#config#Init()
    call tidyterm#session#Init()
    call tidyterm#history#Init()
    call tidyterm#integration#Init()
    call tidyterm#statusline#Init()
    
    augroup tidyterm_auto_session
        autocmd!
        autocmd VimEnter * call tidyterm#session#SwitchToProject()
        autocmd VimLeave * call tidyterm#session#Save()
        autocmd BufEnter * if &buftype ==# 'terminal' | call tidyterm#session#Clean() | endif
    augroup END
endfunction

function! tidyterm#Toggle(...) abort
    let l:terminal_name = a:0 > 0 ? a:1 : 'default'
    
    if tidyterm#terminal#Active(l:terminal_name)
        call tidyterm#terminal#Hide(l:terminal_name)
    else
        call tidyterm#terminal#Show(l:terminal_name)
    endif
endfunction

function! tidyterm#SendCommand(terminal_name, command) abort
    let l:terminals = tidyterm#session#GetTerminals()
    
    if !has_key(l:terminals, a:terminal_name)
        call tidyterm#Toggle(a:terminal_name)
        let l:terminals = tidyterm#session#GetTerminals()
    endif
    
    let l:buffer_info = l:terminals[a:terminal_name]
    
    if !tidyterm#terminal#Active(a:terminal_name)
        call tidyterm#terminal#Show(a:terminal_name)
    endif
    
    if has_key(l:buffer_info, 'bufnr') && bufexists(l:buffer_info['bufnr'])
        if has('nvim')
            call chansend(l:buffer_info['bufnr'], a:command . "\n")
        else
            call term_sendkeys(l:buffer_info['bufnr'], a:command . "\n")
        endif
        
        call tidyterm#history#AddEntry(a:terminal_name, a:command, getcwd())
    endif
endfunction

function! tidyterm#List() abort
    let l:terminals = tidyterm#session#GetTerminals()
    let l:result = []
    
    for [l:name, l:info] in items(l:terminals)
        let l:active = tidyterm#terminal#Active(l:name) ? '*' : ' '
        let l:bufnr = get(l:info, 'bufnr', -1)
        let l:position = get(l:info, 'position', 'unknown')
        call add(l:result, printf('%s %-15s (buf:%d, pos:%s)', l:active, l:name, l:bufnr, l:position))
    endfor
    
    return l:result
endfunction

function! tidyterm#Kill(terminal_name) abort
    let l:terminals = tidyterm#session#GetTerminals()
    
    if has_key(l:terminals, a:terminal_name)
        let l:buffer_info = l:terminals[a:terminal_name]
        
        if tidyterm#terminal#Active(a:terminal_name)
            call tidyterm#terminal#Hide(a:terminal_name)
        endif
        
        if has_key(l:buffer_info, 'bufnr') && bufexists(l:buffer_info['bufnr'])
            execute 'bdelete! ' . l:buffer_info['bufnr']
        endif
        
        call tidyterm#session#RemoveTerminal(a:terminal_name)
    endif
endfunction

function! tidyterm#Rename(old_name, new_name) abort
    let l:terminals = tidyterm#session#GetTerminals()
    
    if has_key(l:terminals, a:old_name) && !has_key(l:terminals, a:new_name)
        let l:buffer_info = l:terminals[a:old_name]
        call tidyterm#session#RemoveTerminal(a:old_name)
        call tidyterm#session#AddTerminal(a:new_name, l:buffer_info)
    endif
endfunction

function! tidyterm#NextTerminal() abort
    let l:terminals = keys(tidyterm#session#GetTerminals())
    let l:current = tidyterm#session#GetLastTerminal()
    
    if empty(l:terminals)
        return
    endif
    
    let l:index = index(l:terminals, l:current)
    let l:next_index = (l:index + 1) % len(l:terminals)
    let l:next_terminal = l:terminals[l:next_index]
    
    call tidyterm#Toggle(l:next_terminal)
endfunction

function! tidyterm#PrevTerminal() abort
    let l:terminals = keys(tidyterm#session#GetTerminals())
    let l:current = tidyterm#session#GetLastTerminal()
    
    if empty(l:terminals)
        return
    endif
    
    let l:index = index(l:terminals, l:current)
    let l:prev_index = (l:index - 1 + len(l:terminals)) % len(l:terminals)
    let l:prev_terminal = l:terminals[l:prev_index]
    
    call tidyterm#Toggle(l:prev_terminal)
endfunction

