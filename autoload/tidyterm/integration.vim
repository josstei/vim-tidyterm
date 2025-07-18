let s:integrations = {}

function! tidyterm#integration#Init() abort
    let s:integrations = {
        \ 'git': {
        \   'enabled': 1,
        \   'commands': {
        \     'status': 'git status',
        \     'add': 'git add .',
        \     'commit': 'git commit -m "%s"',
        \     'push': 'git push',
        \     'pull': 'git pull',
        \     'log': 'git log --oneline -10',
        \     'diff': 'git diff',
        \     'branch': 'git branch -a'
        \   }
        \ },
        \ 'build': {
        \   'enabled': 1,
        \   'commands': {},
        \   'auto_detect': 1
        \ },
        \ 'test': {
        \   'enabled': 1,
        \   'commands': {},
        \   'auto_detect': 1
        \ }
        \ }
    
    call tidyterm#integration#DetectBuildSystem()
    call tidyterm#integration#DetectTestFramework()
endfunction

function! tidyterm#integration#DetectBuildSystem() abort
    if !tidyterm#config#Get('shell_integration')
        return
    endif
    
    let l:project_root = tidyterm#session#GetProjectRoot()
    
    if filereadable(l:project_root . '/package.json')
        let s:integrations['build']['commands'] = {
            \ 'build': 'npm run build',
            \ 'dev': 'npm run dev',
            \ 'start': 'npm start',
            \ 'install': 'npm install'
            \ }
    elseif filereadable(l:project_root . '/Cargo.toml')
        let s:integrations['build']['commands'] = {
            \ 'build': 'cargo build',
            \ 'release': 'cargo build --release',
            \ 'run': 'cargo run',
            \ 'check': 'cargo check'
            \ }
    elseif filereadable(l:project_root . '/go.mod')
        let s:integrations['build']['commands'] = {
            \ 'build': 'go build',
            \ 'run': 'go run .',
            \ 'test': 'go test ./...',
            \ 'mod': 'go mod tidy'
            \ }
    elseif filereadable(l:project_root . '/Makefile')
        let s:integrations['build']['commands'] = {
            \ 'build': 'make',
            \ 'clean': 'make clean',
            \ 'install': 'make install'
            \ }
    elseif filereadable(l:project_root . '/setup.py')
        let s:integrations['build']['commands'] = {
            \ 'build': 'python setup.py build',
            \ 'install': 'pip install -e .',
            \ 'test': 'python -m pytest'
            \ }
    endif
endfunction

function! tidyterm#integration#DetectTestFramework() abort
    if !tidyterm#config#Get('shell_integration')
        return
    endif
    
    let l:project_root = tidyterm#session#GetProjectRoot()
    
    if filereadable(l:project_root . '/package.json')
        let s:integrations['test']['commands'] = {
            \ 'test': 'npm test',
            \ 'test-watch': 'npm run test:watch',
            \ 'coverage': 'npm run coverage'
            \ }
    elseif filereadable(l:project_root . '/Cargo.toml')
        let s:integrations['test']['commands'] = {
            \ 'test': 'cargo test',
            \ 'test-verbose': 'cargo test -- --nocapture',
            \ 'bench': 'cargo bench'
            \ }
    elseif filereadable(l:project_root . '/pytest.ini') || filereadable(l:project_root . '/setup.cfg')
        let s:integrations['test']['commands'] = {
            \ 'test': 'pytest',
            \ 'test-verbose': 'pytest -v',
            \ 'coverage': 'pytest --cov'
            \ }
    elseif executable('go') && filereadable(l:project_root . '/go.mod')
        let s:integrations['test']['commands'] = {
            \ 'test': 'go test ./...',
            \ 'test-verbose': 'go test -v ./...',
            \ 'bench': 'go test -bench=.'
            \ }
    endif
endfunction

function! tidyterm#integration#RunCommand(category, command, ...) abort
    if !has_key(s:integrations, a:category) || !s:integrations[a:category]['enabled']
        echom 'Integration not available: ' . a:category
        return
    endif
    
    let l:commands = s:integrations[a:category]['commands']
    if !has_key(l:commands, a:command)
        echom 'Command not found: ' . a:command . ' in ' . a:category
        return
    endif
    
    let l:cmd = l:commands[a:command]
    
    if a:0 > 0
        let l:cmd = printf(l:cmd, a:1)
    endif
    
    let l:terminal_name = a:category . '_' . a:command
    call tidyterm#SendCommand(l:terminal_name, l:cmd)
endfunction

function! tidyterm#integration#GitStatus() abort
    call tidyterm#integration#RunCommand('git', 'status')
endfunction

function! tidyterm#integration#GitAdd() abort
    call tidyterm#integration#RunCommand('git', 'add')
endfunction

function! tidyterm#integration#GitCommit(...) abort
    if a:0 > 0
        call tidyterm#integration#RunCommand('git', 'commit', a:1)
    else
        let l:message = input('Commit message: ')
        if !empty(l:message)
            call tidyterm#integration#RunCommand('git', 'commit', l:message)
        endif
    endif
endfunction

function! tidyterm#integration#GitPush() abort
    call tidyterm#integration#RunCommand('git', 'push')
endfunction

function! tidyterm#integration#GitPull() abort
    call tidyterm#integration#RunCommand('git', 'pull')
endfunction

function! tidyterm#integration#GitLog() abort
    call tidyterm#integration#RunCommand('git', 'log')
endfunction

function! tidyterm#integration#GitDiff() abort
    call tidyterm#integration#RunCommand('git', 'diff')
endfunction

function! tidyterm#integration#Build() abort
    call tidyterm#integration#RunCommand('build', 'build')
endfunction

function! tidyterm#integration#Run() abort
    if has_key(s:integrations['build']['commands'], 'run')
        call tidyterm#integration#RunCommand('build', 'run')
    elseif has_key(s:integrations['build']['commands'], 'dev')
        call tidyterm#integration#RunCommand('build', 'dev')
    else
        echom 'No run command available'
    endif
endfunction

function! tidyterm#integration#Test() abort
    call tidyterm#integration#RunCommand('test', 'test')
endfunction

function! tidyterm#integration#TestVerbose() abort
    if has_key(s:integrations['test']['commands'], 'test-verbose')
        call tidyterm#integration#RunCommand('test', 'test-verbose')
    else
        call tidyterm#integration#RunCommand('test', 'test')
    endif
endfunction

function! tidyterm#integration#Coverage() abort
    if has_key(s:integrations['test']['commands'], 'coverage')
        call tidyterm#integration#RunCommand('test', 'coverage')
    else
        echom 'No coverage command available'
    endif
endfunction

function! tidyterm#integration#GetAvailableCommands(category) abort
    if has_key(s:integrations, a:category)
        return keys(s:integrations[a:category]['commands'])
    endif
    return []
endfunction

function! tidyterm#integration#AddCustomCommand(category, name, command) abort
    if !has_key(s:integrations, a:category)
        let s:integrations[a:category] = {'enabled': 1, 'commands': {}}
    endif
    
    let s:integrations[a:category]['commands'][a:name] = a:command
endfunction

function! tidyterm#integration#RemoveCustomCommand(category, name) abort
    if has_key(s:integrations, a:category) && has_key(s:integrations[a:category]['commands'], a:name)
        unlet s:integrations[a:category]['commands'][a:name]
    endif
endfunction

function! tidyterm#integration#ListIntegrations() abort
    let l:result = []
    for [l:category, l:config] in items(s:integrations)
        if l:config['enabled']
            let l:commands = keys(l:config['commands'])
            if !empty(l:commands)
                call add(l:result, {'category': l:category, 'commands': l:commands})
            endif
        endif
    endfor
    return l:result
endfunction

function! tidyterm#integration#EnableIntegration(category) abort
    if has_key(s:integrations, a:category)
        let s:integrations[a:category]['enabled'] = 1
    endif
endfunction

function! tidyterm#integration#DisableIntegration(category) abort
    if has_key(s:integrations, a:category)
        let s:integrations[a:category]['enabled'] = 0
    endif
endfunction

function! tidyterm#integration#SendToTerminal(text) abort
    let l:terminal_name = tidyterm#session#GetLastTerminal()
    let l:terminals = tidyterm#session#GetTerminals()
    
    if !has_key(l:terminals, l:terminal_name)
        call tidyterm#Toggle(l:terminal_name)
    endif
    
    let l:buffer_info = l:terminals[l:terminal_name]
    
    if has_key(l:buffer_info, 'bufnr') && bufexists(l:buffer_info['bufnr'])
        call tidyterm#window#Focus(l:terminal_name, l:buffer_info)
        
        if has('nvim')
            call chansend(l:buffer_info['bufnr'], a:text . "\n")
        else
            call term_sendkeys(l:buffer_info['bufnr'], a:text . "\n")
        endif
    endif
endfunction

function! tidyterm#integration#SendCurrentLine() abort
    let l:line = getline('.')
    call tidyterm#integration#SendToTerminal(l:line)
endfunction

function! tidyterm#integration#SendSelection() abort
    let l:save_reg = @"
    normal! gvy
    let l:text = @"
    let @" = l:save_reg
    
    call tidyterm#integration#SendToTerminal(l:text)
endfunction