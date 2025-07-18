let s:sessions = {}
let s:current_session = 'default'
let s:session_file = expand('~/.vim/tidyterm_sessions.json')

function! tidyterm#session#Init() abort
    if !isdirectory(fnamemodify(s:session_file, ':h'))
        call mkdir(fnamemodify(s:session_file, ':h'), 'p')
    endif
    call tidyterm#session#Load()
endfunction

function! tidyterm#session#GetCurrent() abort
    return s:current_session
endfunction

function! tidyterm#session#SetCurrent(name) abort
    let s:current_session = a:name
    if !has_key(s:sessions, a:name)
        let s:sessions[a:name] = {
            \ 'terminals': {},
            \ 'last_terminal': 'default',
            \ 'created': strftime('%Y-%m-%d %H:%M:%S')
            \ }
    endif
endfunction

function! tidyterm#session#List() abort
    return keys(s:sessions)
endfunction

function! tidyterm#session#GetTerminals(...) abort
    let l:session_name = a:0 > 0 ? a:1 : s:current_session
    if !has_key(s:sessions, l:session_name)
        return {}
    endif
    return s:sessions[l:session_name]['terminals']
endfunction

function! tidyterm#session#AddTerminal(terminal_name, buffer_info) abort
    if !has_key(s:sessions, s:current_session)
        call tidyterm#session#SetCurrent(s:current_session)
    endif
    
    let s:sessions[s:current_session]['terminals'][a:terminal_name] = a:buffer_info
    let s:sessions[s:current_session]['last_terminal'] = a:terminal_name
    call tidyterm#session#Save()
endfunction

function! tidyterm#session#RemoveTerminal(terminal_name) abort
    if has_key(s:sessions, s:current_session) && has_key(s:sessions[s:current_session]['terminals'], a:terminal_name)
        unlet s:sessions[s:current_session]['terminals'][a:terminal_name]
        
        if s:sessions[s:current_session]['last_terminal'] ==# a:terminal_name
            let l:terminals = keys(s:sessions[s:current_session]['terminals'])
            let s:sessions[s:current_session]['last_terminal'] = len(l:terminals) > 0 ? l:terminals[0] : 'default'
        endif
        
        call tidyterm#session#Save()
    endif
endfunction

function! tidyterm#session#GetLastTerminal() abort
    if has_key(s:sessions, s:current_session)
        return s:sessions[s:current_session]['last_terminal']
    endif
    return 'default'
endfunction

function! tidyterm#session#Save() abort
    if !tidyterm#config#Get('session_persistence')
        return
    endif
    
    try
        let l:json_data = json_encode(s:sessions)
        call writefile([l:json_data], s:session_file)
    catch
        echom 'TidyTerm: Failed to save session data'
    endtry
endfunction

function! tidyterm#session#Load() abort
    if !tidyterm#config#Get('session_persistence') || !filereadable(s:session_file)
        return
    endif
    
    try
        let l:json_data = readfile(s:session_file)[0]
        let s:sessions = json_decode(l:json_data)
        
        let l:project_root = tidyterm#session#GetProjectRoot()
        if has_key(s:sessions, l:project_root)
            let s:current_session = l:project_root
        endif
    catch
        let s:sessions = {}
    endtry
endfunction

function! tidyterm#session#GetProjectRoot() abort
    let l:markers = ['.git', '.hg', '.svn', 'package.json', 'Cargo.toml', 'go.mod']
    let l:current_dir = getcwd()
    
    for l:marker in l:markers
        let l:found = findfile(l:marker, l:current_dir . ';')
        if !empty(l:found)
            return fnamemodify(l:found, ':h')
        endif
        let l:found = finddir(l:marker, l:current_dir . ';')
        if !empty(l:found)
            return fnamemodify(l:found, ':h')
        endif
    endfor
    
    return l:current_dir
endfunction

function! tidyterm#session#SwitchToProject() abort
    let l:project_root = tidyterm#session#GetProjectRoot()
    if l:project_root !=# s:current_session
        call tidyterm#session#SetCurrent(l:project_root)
    endif
endfunction

function! tidyterm#session#Delete(session_name) abort
    if has_key(s:sessions, a:session_name)
        unlet s:sessions[a:session_name]
        if s:current_session ==# a:session_name
            let s:current_session = 'default'
        endif
        call tidyterm#session#Save()
    endif
endfunction

function! tidyterm#session#Clean() abort
    for l:session_name in keys(s:sessions)
        let l:terminals = s:sessions[l:session_name]['terminals']
        for l:terminal_name in keys(l:terminals)
            let l:bufnr = l:terminals[l:terminal_name]['bufnr']
            if !bufexists(l:bufnr) || !buflisted(l:bufnr)
                unlet l:terminals[l:terminal_name]
            endif
        endfor
        
        if empty(l:terminals)
            unlet s:sessions[l:session_name]
        endif
    endfor
    call tidyterm#session#Save()
endfunction