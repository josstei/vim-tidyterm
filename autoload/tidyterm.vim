function! tidyterm#Toggle() abort
    if tidyterm#terminal#Active()
        call tidyterm#terminal#Hide()
    else
        call tidyterm#terminal#Show()
    endif
endfunction

