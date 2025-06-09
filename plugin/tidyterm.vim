if exists('g:tidyterm_loaded')
    finish
endif

if !exists('g:tidyterm_autostart')
    let g:tidyterm_autostart=0
endif

if !exists('g:tidyterm_size')
    let g:tidyterm_size=15
endif

if !exists('g:tidyterm_position')
    let g:tidyterm_position = 'bottom'
    let g:tidyterm_size=15
endif

let g:tidyterm_loaded   = 1
let g:term_bufnr        = -1
let g:term_winid        = -1
let g:prev_winid        = -1

command! TidyTerm call TidyTermToggle()

augroup tidyterm_terminal_settings
    autocmd!
    autocmd VimEnter * if g:tidyterm_autostart | call TidyTermToggle() | setlocal nonumber norelativenumber | endif
    autocmd BufEnter * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber | endif
augroup END

function! TidyTermToggle() abort
    try
        call TidyTermCompatible()
        call tidyterm#Toggle()
    catch /*./
        echom 'TidyTerm: ' . v:exception
    endtry
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
