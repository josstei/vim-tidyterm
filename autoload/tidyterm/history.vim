let s:history = {}
let s:current_index = {}

function! tidyterm#history#Init() abort
    let s:history = {}
    let s:current_index = {}
endfunction

function! tidyterm#history#AddEntry(terminal_name, command, directory) abort
    if !has_key(s:history, a:terminal_name)
        let s:history[a:terminal_name] = []
        let s:current_index[a:terminal_name] = -1
    endif
    
    let l:entry = {
        \ 'command': a:command,
        \ 'directory': a:directory,
        \ 'timestamp': localtime()
        \ }
    
    call add(s:history[a:terminal_name], l:entry)
    
    let l:max_size = tidyterm#config#Get('history_size')
    if len(s:history[a:terminal_name]) > l:max_size
        call remove(s:history[a:terminal_name], 0)
    endif
    
    let s:current_index[a:terminal_name] = len(s:history[a:terminal_name]) - 1
endfunction

function! tidyterm#history#GetHistory(terminal_name) abort
    return get(s:history, a:terminal_name, [])
endfunction

function! tidyterm#history#GetPrevious(terminal_name) abort
    if !has_key(s:history, a:terminal_name) || empty(s:history[a:terminal_name])
        return ''
    endif
    
    let l:current = s:current_index[a:terminal_name]
    if l:current > 0
        let s:current_index[a:terminal_name] = l:current - 1
    endif
    
    return s:history[a:terminal_name][s:current_index[a:terminal_name]]['command']
endfunction

function! tidyterm#history#GetNext(terminal_name) abort
    if !has_key(s:history, a:terminal_name) || empty(s:history[a:terminal_name])
        return ''
    endif
    
    let l:current = s:current_index[a:terminal_name]
    let l:max_index = len(s:history[a:terminal_name]) - 1
    
    if l:current < l:max_index
        let s:current_index[a:terminal_name] = l:current + 1
        return s:history[a:terminal_name][s:current_index[a:terminal_name]]['command']
    endif
    
    return ''
endfunction

function! tidyterm#history#Search(terminal_name, pattern) abort
    if !has_key(s:history, a:terminal_name)
        return []
    endif
    
    let l:matches = []
    for l:entry in s:history[a:terminal_name]
        if l:entry['command'] =~? a:pattern
            call add(l:matches, l:entry)
        endif
    endfor
    
    return l:matches
endfunction

function! tidyterm#history#Clear(terminal_name) abort
    if has_key(s:history, a:terminal_name)
        let s:history[a:terminal_name] = []
        let s:current_index[a:terminal_name] = -1
    endif
endfunction

function! tidyterm#history#GetStats(terminal_name) abort
    if !has_key(s:history, a:terminal_name)
        return {'total': 0, 'unique': 0}
    endif
    
    let l:total = len(s:history[a:terminal_name])
    let l:unique_commands = {}
    
    for l:entry in s:history[a:terminal_name]
        let l:unique_commands[l:entry['command']] = 1
    endfor
    
    return {'total': l:total, 'unique': len(l:unique_commands)}
endfunction

function! tidyterm#history#GetRecentDirectories(terminal_name) abort
    if !has_key(s:history, a:terminal_name)
        return []
    endif
    
    let l:dirs = {}
    for l:entry in s:history[a:terminal_name]
        let l:dirs[l:entry['directory']] = l:entry['timestamp']
    endfor
    
    let l:sorted_dirs = []
    for [l:dir, l:timestamp] in items(l:dirs)
        call add(l:sorted_dirs, {'directory': l:dir, 'timestamp': l:timestamp})
    endfor
    
    return sort(l:sorted_dirs, {a, b -> b['timestamp'] - a['timestamp']})
endfunction

function! tidyterm#history#GetMostUsedCommands(terminal_name) abort
    if !has_key(s:history, a:terminal_name)
        return []
    endif
    
    let l:command_count = {}
    for l:entry in s:history[a:terminal_name]
        let l:cmd = l:entry['command']
        let l:command_count[l:cmd] = get(l:command_count, l:cmd, 0) + 1
    endfor
    
    let l:sorted_commands = []
    for [l:cmd, l:count] in items(l:command_count)
        call add(l:sorted_commands, {'command': l:cmd, 'count': l:count})
    endfor
    
    return sort(l:sorted_commands, {a, b -> b['count'] - a['count']})
endfunction

function! tidyterm#history#ExportHistory(terminal_name, filename) abort
    if !has_key(s:history, a:terminal_name)
        echom 'No history found for terminal: ' . a:terminal_name
        return
    endif
    
    let l:lines = []
    for l:entry in s:history[a:terminal_name]
        let l:timestamp = strftime('%Y-%m-%d %H:%M:%S', l:entry['timestamp'])
        let l:line = l:timestamp . ' | ' . l:entry['directory'] . ' | ' . l:entry['command']
        call add(l:lines, l:line)
    endfor
    
    try
        call writefile(l:lines, a:filename)
        echom 'History exported to: ' . a:filename
    catch
        echom 'Failed to export history: ' . v:exception
    endtry
endfunction

function! tidyterm#history#ImportHistory(terminal_name, filename) abort
    if !filereadable(a:filename)
        echom 'File not found: ' . a:filename
        return
    endif
    
    try
        let l:lines = readfile(a:filename)
        let s:history[a:terminal_name] = []
        
        for l:line in l:lines
            let l:parts = split(l:line, ' | ')
            if len(l:parts) >= 3
                let l:timestamp = strptime('%Y-%m-%d %H:%M:%S', l:parts[0])
                let l:directory = l:parts[1]
                let l:command = join(l:parts[2:], ' | ')
                
                let l:entry = {
                    \ 'command': l:command,
                    \ 'directory': l:directory,
                    \ 'timestamp': l:timestamp
                    \ }
                
                call add(s:history[a:terminal_name], l:entry)
            endif
        endfor
        
        let s:current_index[a:terminal_name] = len(s:history[a:terminal_name]) - 1
        echom 'History imported from: ' . a:filename
    catch
        echom 'Failed to import history: ' . v:exception
    endtry
endfunction