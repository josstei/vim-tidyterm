let s:floating_windows = {}
let s:size_cache = {}

function! tidyterm#window#Open(terminal_name, buffer_info) abort
    let l:position = tidyterm#config#Get('smart_position') ? tidyterm#config#GetSmartPosition() : tidyterm#config#Get('position')
    
    if l:position ==# 'floating' && has('nvim')
        return tidyterm#window#OpenFloating(a:terminal_name, a:buffer_info)
    else
        return tidyterm#window#OpenSplit(a:terminal_name, a:buffer_info, l:position)
    endif
endfunction

function! tidyterm#window#OpenSplit(terminal_name, buffer_info, position) abort
    let l:position_map = tidyterm#config#GetPositionMap()
    
    if a:position !=# 'floating'
        let l:position_map = copy(l:position_map[a:position])
        let l:position_map['size'] = tidyterm#window#GetCachedSize(a:terminal_name, a:position, l:position_map['size'])
    endif
    
    execute l:position_map['position'] . ' ' . l:position_map['split']
    
    if has_key(a:buffer_info, 'bufnr') && bufexists(a:buffer_info['bufnr'])
        execute 'buffer ' . a:buffer_info['bufnr']
    else
        call tidyterm#buffer#CallTerminal()
        let a:buffer_info['bufnr'] = bufnr('%')
    endif
    
    execute l:position_map['resize'] . ' ' . l:position_map['size']
    
    let l:winid = win_getid()
    let a:buffer_info['winid'] = l:winid
    let a:buffer_info['position'] = a:position
    
    call tidyterm#window#SetupWindow(a:terminal_name)
    
    return l:winid
endfunction

function! tidyterm#window#OpenFloating(terminal_name, buffer_info) abort
    if !has('nvim')
        echom 'TidyTerm: Floating windows only supported in Neovim'
        return tidyterm#window#OpenSplit(a:terminal_name, a:buffer_info, 'bottom')
    endif
    
    let l:width = float2nr(&columns * tidyterm#config#Get('floating_width'))
    let l:height = float2nr(&lines * tidyterm#config#Get('floating_height'))
    let l:col = float2nr((&columns - l:width) / 2)
    let l:row = float2nr((&lines - l:height) / 2)
    
    let l:opts = {
        \ 'relative': 'editor',
        \ 'width': l:width,
        \ 'height': l:height,
        \ 'col': l:col,
        \ 'row': l:row,
        \ 'style': 'minimal'
        \ }
    
    let l:border = tidyterm#config#Get('floating_border')
    if l:border !=# 'none'
        let l:opts['border'] = l:border
    endif
    
    if has_key(a:buffer_info, 'bufnr') && bufexists(a:buffer_info['bufnr'])
        let l:bufnr = a:buffer_info['bufnr']
    else
        let l:bufnr = nvim_create_buf(v:false, v:true)
        let a:buffer_info['bufnr'] = l:bufnr
    endif
    
    let l:winid = nvim_open_win(l:bufnr, v:true, l:opts)
    
    if !has_key(a:buffer_info, 'terminal_created')
        call termopen(&shell)
        let a:buffer_info['terminal_created'] = v:true
    endif
    
    let s:floating_windows[a:terminal_name] = {
        \ 'winid': l:winid,
        \ 'bufnr': l:bufnr,
        \ 'opts': l:opts
        \ }
    
    let a:buffer_info['winid'] = l:winid
    let a:buffer_info['position'] = 'floating'
    
    call tidyterm#window#SetupWindow(a:terminal_name)
    
    return l:winid
endfunction

function! tidyterm#window#Close(terminal_name, buffer_info) abort
    if has_key(a:buffer_info, 'position') && a:buffer_info['position'] ==# 'floating'
        call tidyterm#window#CloseFloating(a:terminal_name)
    else
        call tidyterm#window#CloseSplit(a:terminal_name, a:buffer_info)
    endif
endfunction

function! tidyterm#window#CloseSplit(terminal_name, buffer_info) abort
    if has_key(a:buffer_info, 'winid') && win_gotoid(a:buffer_info['winid'])
        if tidyterm#config#Get('remember_size')
            call tidyterm#window#CacheSize(a:terminal_name, a:buffer_info['position'])
        endif
        close!
    endif
    
    if has_key(a:buffer_info, 'winid')
        unlet a:buffer_info['winid']
    endif
endfunction

function! tidyterm#window#CloseFloating(terminal_name) abort
    if has_key(s:floating_windows, a:terminal_name)
        let l:winid = s:floating_windows[a:terminal_name]['winid']
        if nvim_win_is_valid(l:winid)
            call nvim_win_close(l:winid, v:true)
        endif
        unlet s:floating_windows[a:terminal_name]
    endif
endfunction

function! tidyterm#window#IsActive(terminal_name, buffer_info) abort
    if has_key(a:buffer_info, 'position') && a:buffer_info['position'] ==# 'floating'
        return tidyterm#window#IsFloatingActive(a:terminal_name)
    else
        return tidyterm#window#IsSplitActive(a:buffer_info)
    endif
endfunction

function! tidyterm#window#IsSplitActive(buffer_info) abort
    if !has_key(a:buffer_info, 'winid')
        return 0
    endif
    
    return win_gotoid(a:buffer_info['winid']) && &buftype ==# 'terminal'
endfunction

function! tidyterm#window#IsFloatingActive(terminal_name) abort
    if !has_key(s:floating_windows, a:terminal_name)
        return 0
    endif
    
    let l:winid = s:floating_windows[a:terminal_name]['winid']
    return has('nvim') && nvim_win_is_valid(l:winid)
endfunction

function! tidyterm#window#Focus(terminal_name, buffer_info) abort
    if has_key(a:buffer_info, 'position') && a:buffer_info['position'] ==# 'floating'
        call tidyterm#window#FocusFloating(a:terminal_name)
    else
        call tidyterm#window#FocusSplit(a:buffer_info)
    endif
    
    if tidyterm#config#Get('focus_on_toggle')
        if has('nvim')
            startinsert
        elseif &buftype ==# 'terminal' && mode() ==# 'n'
            call feedkeys("i", "n")
        endif
    endif
endfunction

function! tidyterm#window#FocusSplit(buffer_info) abort
    if has_key(a:buffer_info, 'winid')
        call win_gotoid(a:buffer_info['winid'])
    endif
endfunction

function! tidyterm#window#FocusFloating(terminal_name) abort
    if has_key(s:floating_windows, a:terminal_name)
        let l:winid = s:floating_windows[a:terminal_name]['winid']
        if has('nvim') && nvim_win_is_valid(l:winid)
            call nvim_set_current_win(l:winid)
        endif
    endif
endfunction

function! tidyterm#window#SetupWindow(terminal_name) abort
    setlocal nonumber norelativenumber
    setlocal bufhidden=hide
    setlocal nobuflisted
    
    if tidyterm#config#Get('terminal_title')
        let l:title = 'TidyTerm: ' . a:terminal_name
        if has('nvim')
            execute 'setlocal titlestring=' . escape(l:title, ' ')
        else
            execute 'setlocal statusline=' . escape(l:title, ' ')
        endif
    endif
    
    call tidyterm#buffer#SetFiletype()
    
    if has_key(g:, 'tidyterm_window_setup_hook')
        call g:tidyterm_window_setup_hook(a:terminal_name)
    endif
endfunction

function! tidyterm#window#CacheSize(terminal_name, position) abort
    let l:key = a:terminal_name . '_' . a:position
    
    if a:position ==# 'left' || a:position ==# 'right'
        let s:size_cache[l:key] = winwidth(0)
    elseif a:position ==# 'top' || a:position ==# 'bottom'
        let s:size_cache[l:key] = winheight(0)
    endif
endfunction

function! tidyterm#window#GetCachedSize(terminal_name, position, default_size) abort
    let l:key = a:terminal_name . '_' . a:position
    return get(s:size_cache, l:key, a:default_size)
endfunction

function! tidyterm#window#ChangePosition(terminal_name, new_position) abort
    let l:terminals = tidyterm#session#GetTerminals()
    if !has_key(l:terminals, a:terminal_name)
        return
    endif
    
    let l:buffer_info = l:terminals[a:terminal_name]
    
    if tidyterm#window#IsActive(a:terminal_name, l:buffer_info)
        call tidyterm#window#Close(a:terminal_name, l:buffer_info)
    endif
    
    let l:old_position = tidyterm#config#Get('position')
    call tidyterm#config#Set('position', a:new_position)
    
    let l:winid = tidyterm#window#Open(a:terminal_name, l:buffer_info)
    call tidyterm#window#Focus(a:terminal_name, l:buffer_info)
    
    call tidyterm#session#AddTerminal(a:terminal_name, l:buffer_info)
endfunction

function! tidyterm#window#Resize(terminal_name, size) abort
    let l:terminals = tidyterm#session#GetTerminals()
    if !has_key(l:terminals, a:terminal_name)
        return
    endif
    
    let l:buffer_info = l:terminals[a:terminal_name]
    
    if !tidyterm#window#IsActive(a:terminal_name, l:buffer_info)
        return
    endif
    
    if has_key(l:buffer_info, 'position')
        let l:position = l:buffer_info['position']
        if l:position ==# 'floating'
            return
        endif
        
        let l:position_map = tidyterm#config#GetPositionMap()
        if has_key(l:position_map, l:position)
            execute l:position_map[l:position]['resize'] . ' ' . a:size
        endif
    endif
endfunction