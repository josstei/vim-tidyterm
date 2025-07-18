let s:default_config = {
    \ 'autostart': 0,
    \ 'size': 15,
    \ 'position': 'bottom',
    \ 'filetype': 'tidyterm',
    \ 'session_persistence': 1,
    \ 'floating_window': 0,
    \ 'floating_width': 0.8,
    \ 'floating_height': 0.6,
    \ 'floating_border': 'rounded',
    \ 'smart_position': 1,
    \ 'focus_on_toggle': 1,
    \ 'remember_size': 1,
    \ 'statusline_integration': 1,
    \ 'history_size': 10,
    \ 'shell_integration': 1,
    \ 'send_text_mapping': '<leader>ts',
    \ 'quick_commands': {},
    \ 'auto_cd': 1,
    \ 'terminal_title': 1
    \ }

let s:config_cache = {}

function! tidyterm#config#Init() abort
    let s:config_cache = copy(s:default_config)
    
    for [l:key, l:default_value] in items(s:default_config)
        let l:var_name = 'g:tidyterm_' . l:key
        if exists(l:var_name)
            let s:config_cache[l:key] = eval(l:var_name)
        endif
    endfor
    
    call tidyterm#config#ValidateConfig()
endfunction

function! tidyterm#config#Get(key, ...) abort
    if has_key(s:config_cache, a:key)
        return s:config_cache[a:key]
    endif
    return a:0 > 0 ? a:1 : get(s:default_config, a:key, v:null)
endfunction

function! tidyterm#config#Set(key, value) abort
    let s:config_cache[a:key] = a:value
    let l:var_name = 'g:tidyterm_' . a:key
    execute 'let ' . l:var_name . ' = ' . string(a:value)
endfunction

function! tidyterm#config#GetAll() abort
    return copy(s:config_cache)
endfunction

function! tidyterm#config#ValidateConfig() abort
    if !has_key(s:config_cache, 'position') || index(['bottom', 'top', 'left', 'right', 'floating'], s:config_cache['position']) == -1
        let s:config_cache['position'] = 'bottom'
    endif
    
    if !has_key(s:config_cache, 'size') || s:config_cache['size'] < 1
        let s:config_cache['size'] = 15
    endif
    
    if !has_key(s:config_cache, 'floating_width') || s:config_cache['floating_width'] <= 0 || s:config_cache['floating_width'] > 1
        let s:config_cache['floating_width'] = 0.8
    endif
    
    if !has_key(s:config_cache, 'floating_height') || s:config_cache['floating_height'] <= 0 || s:config_cache['floating_height'] > 1
        let s:config_cache['floating_height'] = 0.6
    endif
    
    if !has_key(s:config_cache, 'floating_border') || index(['none', 'single', 'double', 'rounded', 'solid', 'shadow'], s:config_cache['floating_border']) == -1
        let s:config_cache['floating_border'] = 'rounded'
    endif
    
    if !has_key(s:config_cache, 'history_size') || s:config_cache['history_size'] < 1
        let s:config_cache['history_size'] = 10
    endif
    
    if s:config_cache['position'] ==# 'floating' && !has('nvim')
        let s:config_cache['position'] = 'bottom'
        echom 'TidyTerm: Floating windows only supported in Neovim, falling back to bottom'
    endif
endfunction

function! tidyterm#config#GetPositionMap() abort
    let l:base_map = {
        \ 'left': {
        \   'split': 'vsplit',
        \   'position': 'topleft',
        \   'resize': 'vertical resize',
        \   'size': 50
        \ },
        \ 'right': {
        \   'split': 'vsplit',
        \   'position': 'botright',
        \   'resize': 'vertical resize',
        \   'size': 50
        \ },
        \ 'top': {
        \   'split': 'split',
        \   'position': 'topleft',
        \   'resize': 'resize',
        \   'size': 15
        \ },
        \ 'bottom': {
        \   'split': 'split',
        \   'position': 'botright',
        \   'resize': 'resize',
        \   'size': 15
        \ },
        \ 'floating': {
        \   'split': 'floating',
        \   'position': 'center',
        \   'resize': 'floating_resize',
        \   'size': 0
        \ }
        \ }
    
    let l:position = tidyterm#config#Get('position')
    if has_key(l:base_map, l:position)
        let l:map = copy(l:base_map[l:position])
        let l:map['size'] = tidyterm#config#Get('size', l:map['size'])
        return l:map
    endif
    
    return l:base_map['bottom']
endfunction

function! tidyterm#config#GetSmartPosition() abort
    if !tidyterm#config#Get('smart_position')
        return tidyterm#config#Get('position')
    endif
    
    let l:width = &columns
    let l:height = &lines
    
    if l:width > l:height * 2
        return 'right'
    elseif l:height > l:width
        return 'bottom'
    else
        return tidyterm#config#Get('position')
    endif
endfunction

function! tidyterm#config#AddQuickCommand(name, command) abort
    let l:quick_commands = tidyterm#config#Get('quick_commands')
    let l:quick_commands[a:name] = a:command
    call tidyterm#config#Set('quick_commands', l:quick_commands)
endfunction

function! tidyterm#config#RemoveQuickCommand(name) abort
    let l:quick_commands = tidyterm#config#Get('quick_commands')
    if has_key(l:quick_commands, a:name)
        unlet l:quick_commands[a:name]
        call tidyterm#config#Set('quick_commands', l:quick_commands)
    endif
endfunction

function! tidyterm#config#GetQuickCommands() abort
    return tidyterm#config#Get('quick_commands')
endfunction