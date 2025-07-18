if exists('g:tidyterm_loaded')
    finish
endif

let g:tidyterm_loaded = 1

call tidyterm#Init()

command! -nargs=? TidyTerm call TidyTermToggle(<q-args>)
command! -nargs=0 TidyTermList call TidyTermList()
command! -nargs=1 TidyTermKill call TidyTermKill(<q-args>)
command! -nargs=+ TidyTermRename call TidyTermRename(<f-args>)
command! -nargs=0 TidyTermNext call TidyTermNext()
command! -nargs=0 TidyTermPrev call TidyTermPrev()
command! -nargs=+ TidyTermSend call TidyTermSend(<f-args>)
command! -nargs=1 TidyTermPosition call TidyTermPosition(<q-args>)
command! -nargs=+ TidyTermResize call TidyTermResize(<f-args>)
command! -nargs=? TidyTermSession call TidyTermSession(<q-args>)
command! -nargs=0 TidyTermClean call TidyTermClean()
command! -nargs=0 TidyTermConfig call TidyTermConfig()

command! -nargs=0 TidyTermGitStatus call tidyterm#integration#GitStatus()
command! -nargs=0 TidyTermGitAdd call tidyterm#integration#GitAdd()
command! -nargs=? TidyTermGitCommit call tidyterm#integration#GitCommit(<q-args>)
command! -nargs=0 TidyTermGitPush call tidyterm#integration#GitPush()
command! -nargs=0 TidyTermGitPull call tidyterm#integration#GitPull()
command! -nargs=0 TidyTermGitLog call tidyterm#integration#GitLog()
command! -nargs=0 TidyTermGitDiff call tidyterm#integration#GitDiff()
command! -nargs=0 TidyTermBuild call tidyterm#integration#Build()
command! -nargs=0 TidyTermRun call tidyterm#integration#Run()
command! -nargs=0 TidyTermTest call tidyterm#integration#Test()
command! -nargs=0 TidyTermTestVerbose call tidyterm#integration#TestVerbose()
command! -nargs=0 TidyTermCoverage call tidyterm#integration#Coverage()
command! -nargs=0 TidyTermSendLine call tidyterm#integration#SendCurrentLine()
command! -range TidyTermSendSelection call tidyterm#integration#SendSelection()

augroup tidyterm_terminal_settings
    autocmd!
    autocmd VimEnter * if tidyterm#config#Get('autostart') | call TidyTermToggle() | endif
    autocmd BufEnter * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber | endif
augroup END

function! TidyTermToggle(...) abort
    try
        call TidyTermCompatible()
        let l:terminal_name = a:0 > 0 && !empty(a:1) ? a:1 : 'default'
        call tidyterm#Toggle(l:terminal_name)
    catch /*./
        echom 'TidyTerm: ' . v:exception
    endtry
endfunction

function! TidyTermList() abort
    let l:terminals = tidyterm#List()
    if empty(l:terminals)
        echo 'No terminals found'
    else
        echo 'Active terminals:'
        for l:terminal in l:terminals
            echo '  ' . l:terminal
        endfor
    endif
endfunction

function! TidyTermKill(terminal_name) abort
    call tidyterm#Kill(a:terminal_name)
    echo 'Killed terminal: ' . a:terminal_name
endfunction

function! TidyTermRename(old_name, new_name) abort
    call tidyterm#Rename(a:old_name, a:new_name)
    echo 'Renamed terminal: ' . a:old_name . ' -> ' . a:new_name
endfunction

function! TidyTermNext() abort
    call tidyterm#NextTerminal()
endfunction

function! TidyTermPrev() abort
    call tidyterm#PrevTerminal()
endfunction

function! TidyTermSend(terminal_name, ...) abort
    let l:command = join(a:000, ' ')
    call tidyterm#SendCommand(a:terminal_name, l:command)
endfunction

function! TidyTermPosition(position) abort
    let l:valid_positions = ['bottom', 'top', 'left', 'right', 'floating']
    if index(l:valid_positions, a:position) == -1
        echo 'Invalid position. Valid options: ' . join(l:valid_positions, ', ')
        return
    endif
    
    call tidyterm#config#Set('position', a:position)
    echo 'Terminal position set to: ' . a:position
endfunction

function! TidyTermResize(terminal_name, size) abort
    call tidyterm#window#Resize(a:terminal_name, a:size)
    echo 'Resized terminal ' . a:terminal_name . ' to size: ' . a:size
endfunction

function! TidyTermSession(...) abort
    if a:0 == 0
        echo 'Current session: ' . tidyterm#session#GetCurrent()
        let l:sessions = tidyterm#session#List()
        if len(l:sessions) > 1
            echo 'Available sessions: ' . join(l:sessions, ', ')
        endif
    else
        call tidyterm#session#SetCurrent(a:1)
        echo 'Switched to session: ' . a:1
    endif
endfunction

function! TidyTermClean() abort
    call tidyterm#session#Clean()
    echo 'Cleaned up inactive terminals'
endfunction

function! TidyTermConfig() abort
    let l:config = tidyterm#config#GetAll()
    echo 'TidyTerm Configuration:'
    for [l:key, l:value] in items(l:config)
        echo '  ' . l:key . ': ' . string(l:value)
    endfor
endfunction

function! TidyTermCompatible() abort
        if !exists(':terminal')
            throw "TidyTerm: :terminal command not supported (requires Vim 8.0+ or Neovim 0.2+)"
        endif

        if has('nvim')
            if !exists('v:version') || v:version < 200
                throw "TidyTerm: Requires Neovim 0.2.0 or newer"
            endif
        else
            if !exists('v:version') || v:version < 801
                throw "TidyTerm: Requires Vim 8.1.0085 or newer"
            endif
            if !exists('*win_getid') || !exists('*win_gotoid')
                throw "TidyTerm: Requires Vim with win_getid()/win_gotoid() support (Vim 8.1.0085+)"
            endif
        endif
endfunction
