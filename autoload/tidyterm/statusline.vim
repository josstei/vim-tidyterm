let s:statusline_enabled = 0

function! tidyterm#statusline#Init() abort
    let s:statusline_enabled = tidyterm#config#Get('statusline_integration')
    
    if s:statusline_enabled
        augroup tidyterm_statusline
            autocmd!
            autocmd WinEnter,BufEnter * call tidyterm#statusline#Update()
        augroup END
    endif
endfunction

function! tidyterm#statusline#Update() abort
    if !s:statusline_enabled
        return
    endif
    
    redrawstatus
endfunction

function! tidyterm#statusline#GetInfo() abort
    let l:info = {
        \ 'active_terminals': 0,
        \ 'current_terminal': '',
        \ 'session': tidyterm#session#GetCurrent(),
        \ 'position': tidyterm#config#Get('position'),
        \ 'total_terminals': 0
        \ }
    
    let l:terminals = tidyterm#session#GetTerminals()
    let l:info['total_terminals'] = len(l:terminals)
    
    for [l:name, l:buffer_info] in items(l:terminals)
        if tidyterm#window#IsActive(l:name, l:buffer_info)
            let l:info['active_terminals'] += 1
            let l:info['current_terminal'] = l:name
        endif
    endfor
    
    return l:info
endfunction

function! tidyterm#statusline#GetStatusString() abort
    let l:info = tidyterm#statusline#GetInfo()
    
    if l:info['total_terminals'] == 0
        return ''
    endif
    
    let l:parts = []
    
    if !empty(l:info['current_terminal'])
        call add(l:parts, 'Terminal: ' . l:info['current_terminal'])
    endif
    
    if l:info['total_terminals'] > 1
        call add(l:parts, '(' . l:info['total_terminals'] . ' total)')
    endif
    
    if l:info['session'] !=# 'default'
        call add(l:parts, 'Session: ' . fnamemodify(l:info['session'], ':t'))
    endif
    
    return join(l:parts, ' | ')
endfunction

function! tidyterm#statusline#GetCompactString() abort
    let l:info = tidyterm#statusline#GetInfo()
    
    if l:info['total_terminals'] == 0
        return ''
    endif
    
    let l:status = 'T'
    
    if l:info['active_terminals'] > 0
        let l:status .= ':' . l:info['active_terminals']
    endif
    
    if l:info['total_terminals'] > 1
        let l:status .= '/' . l:info['total_terminals']
    endif
    
    return l:status
endfunction

function! tidyterm#statusline#GetDetailedString() abort
    let l:info = tidyterm#statusline#GetInfo()
    let l:terminals = tidyterm#session#GetTerminals()
    
    if empty(l:terminals)
        return 'No terminals'
    endif
    
    let l:parts = []
    
    call add(l:parts, 'Session: ' . fnamemodify(l:info['session'], ':t'))
    
    let l:terminal_list = []
    for [l:name, l:buffer_info] in items(l:terminals)
        let l:indicator = tidyterm#window#IsActive(l:name, l:buffer_info) ? '*' : ' '
        call add(l:terminal_list, l:indicator . l:name)
    endfor
    
    call add(l:parts, 'Terminals: [' . join(l:terminal_list, ', ') . ']')
    call add(l:parts, 'Position: ' . l:info['position'])
    
    return join(l:parts, ' | ')
endfunction

function! tidyterm#statusline#GetActiveTerminalInfo() abort
    let l:info = tidyterm#statusline#GetInfo()
    
    if empty(l:info['current_terminal'])
        return {}
    endif
    
    let l:terminals = tidyterm#session#GetTerminals()
    let l:terminal_name = l:info['current_terminal']
    
    if !has_key(l:terminals, l:terminal_name)
        return {}
    endif
    
    let l:buffer_info = l:terminals[l:terminal_name]
    let l:result = {
        \ 'name': l:terminal_name,
        \ 'position': get(l:buffer_info, 'position', 'unknown'),
        \ 'bufnr': get(l:buffer_info, 'bufnr', -1),
        \ 'winid': get(l:buffer_info, 'winid', -1)
        \ }
    
    if has_key(l:buffer_info, 'bufnr') && bufexists(l:buffer_info['bufnr'])
        let l:result['buffer_exists'] = 1
        let l:result['buffer_name'] = bufname(l:buffer_info['bufnr'])
    else
        let l:result['buffer_exists'] = 0
    endif
    
    return l:result
endfunction

function! tidyterm#statusline#GetHistoryInfo() abort
    let l:terminals = tidyterm#session#GetTerminals()
    let l:history_info = {}
    
    for l:name in keys(l:terminals)
        let l:stats = tidyterm#history#GetStats(l:name)
        let l:history_info[l:name] = l:stats
    endfor
    
    return l:history_info
endfunction

function! tidyterm#statusline#LightlineIntegration() abort
    return {
        \ 'tidyterm': 'tidyterm#statusline#GetCompactString',
        \ 'tidyterm_detailed': 'tidyterm#statusline#GetStatusString'
        \ }
endfunction

function! tidyterm#statusline#AirlineIntegration() abort
    if exists(':AirlineRefresh')
        function! AirlineInit()
            let g:airline_section_x = airline#section#create_right(['tidyterm'])
        endfunction
        
        autocmd User AirlineAfterInit call AirlineInit()
        
        function! airline#extensions#tidyterm#init(ext) abort
            let a:ext.add_statusline_func('tidyterm#statusline#AirlineStatusline')
        endfunction
        
        function! tidyterm#statusline#AirlineStatusline() abort
            let l:status = tidyterm#statusline#GetCompactString()
            if !empty(l:status)
                call airline#extensions#append_to_section('x', ' ' . l:status . ' ')
            endif
        endfunction
    endif
endfunction

function! tidyterm#statusline#Enable() abort
    let s:statusline_enabled = 1
    call tidyterm#statusline#Init()
endfunction

function! tidyterm#statusline#Disable() abort
    let s:statusline_enabled = 0
    
    if exists('#tidyterm_statusline')
        autocmd! tidyterm_statusline
    endif
endfunction

function! tidyterm#statusline#Toggle() abort
    if s:statusline_enabled
        call tidyterm#statusline#Disable()
    else
        call tidyterm#statusline#Enable()
    endif
endfunction

function! tidyterm#statusline#IsEnabled() abort
    return s:statusline_enabled
endfunction