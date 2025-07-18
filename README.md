![Stable](https://img.shields.io/badge/status-stable-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue)

# vim-tidyterm

**A lightweight Vim/Neovim plugin for quickly toggling a dedicated terminal buffer.**

---

## Features

### Core Features
- **Multiple Named Terminals**: Create and manage multiple terminal instances with custom names
- **Smart Positioning**: Terminals can appear on any side (bottom, top, left, right) or as floating windows (Neovim)
- **Session Management**: Persistent terminal sessions across Vim restarts, with project-specific terminals
- **History Tracking**: Command history with search and navigation capabilities
- **Dynamic Sizing**: Configurable and remembered terminal sizes per position

### Advanced Features
- **Floating Windows**: Modern popup-style terminals in Neovim with customizable borders
- **Send Text to Terminal**: Send current line or selected text directly to terminals
- **Integration Commands**: Built-in Git, build system, and test framework integration
- **Statusline Integration**: Show terminal status in statusline (supports airline/lightline)
- **Auto-detection**: Automatically detects project build systems and test frameworks
- **Quick Commands**: Custom shortcuts for frequently used commands

### Legacy Features
- Quickly toggle (show/hide) persistent terminal buffers
- Optionally autostart terminals when Vim/Neovim opens
- Remembers your previous window and returns you there when hiding terminals
- Compatible with both Vim 8.1+ and Neovim 0.2+

---

## Installation

Use your favorite plugin manager.

### Using [vim-plug](https://github.com/junegunn/vim-plug) (Vimscript)

```vim
Plug 'josstei/vim-tidyterm'
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim) (Lua)

```lua
use 'josstei/vim-tidyterm'
```

After installation, restart Vim/Neovim and run `:PlugInstall`, `:PackerSync`, or the appropriate command for your plugin manager.

---

## Usage

### Commands

#### Basic Terminal Management
```vim
:TidyTerm [name]          " Toggle terminal (default: 'default')
:TidyTermList             " List all terminals
:TidyTermKill <name>      " Kill a specific terminal
:TidyTermRename <old> <new> " Rename a terminal
:TidyTermNext             " Switch to next terminal
:TidyTermPrev             " Switch to previous terminal
:TidyTermSend <name> <cmd> " Send command to terminal
:TidyTermPosition <pos>   " Change terminal position
:TidyTermResize <name> <size> " Resize terminal
:TidyTermSession [name]   " Switch/show sessions
:TidyTermClean            " Clean up inactive terminals
:TidyTermConfig           " Show current configuration
```

#### Integration Commands
```vim
" Git integration
:TidyTermGitStatus        " Run git status
:TidyTermGitAdd           " Run git add .
:TidyTermGitCommit [msg]  " Run git commit
:TidyTermGitPush          " Run git push
:TidyTermGitPull          " Run git pull
:TidyTermGitLog           " Run git log
:TidyTermGitDiff          " Run git diff

" Build/Test integration
:TidyTermBuild            " Run build command
:TidyTermRun              " Run application
:TidyTermTest             " Run tests
:TidyTermTestVerbose      " Run tests with verbose output
:TidyTermCoverage         " Run coverage analysis

" Send text to terminal
:TidyTermSendLine         " Send current line to terminal
:'<,'>TidyTermSendSelection " Send selection to terminal
```

### Example Key Mapping Setup

#### Basic Mappings
```vim
" Toggle default terminal
nnoremap <silent> <C-_> :TidyTerm<CR>
tnoremap <silent> <C-_> <C-\><C-n>:TidyTerm<CR>

" Multiple terminals
nnoremap <silent> <leader>t1 :TidyTerm dev<CR>
nnoremap <silent> <leader>t2 :TidyTerm test<CR>
nnoremap <silent> <leader>t3 :TidyTerm build<CR>

" Terminal navigation
nnoremap <silent> <leader>tn :TidyTermNext<CR>
nnoremap <silent> <leader>tp :TidyTermPrev<CR>
nnoremap <silent> <leader>tl :TidyTermList<CR>
```

#### Advanced Mappings
```vim
" Send text to terminal
nnoremap <silent> <leader>ts :TidyTermSendLine<CR>
vnoremap <silent> <leader>ts :TidyTermSendSelection<CR>

" Git integration
nnoremap <silent> <leader>gs :TidyTermGitStatus<CR>
nnoremap <silent> <leader>ga :TidyTermGitAdd<CR>
nnoremap <silent> <leader>gc :TidyTermGitCommit<CR>
nnoremap <silent> <leader>gp :TidyTermGitPush<CR>

" Build/Test integration
nnoremap <silent> <leader>bb :TidyTermBuild<CR>
nnoremap <silent> <leader>br :TidyTermRun<CR>
nnoremap <silent> <leader>bt :TidyTermTest<CR>

" Position switching
nnoremap <silent> <leader>tb :TidyTermPosition bottom<CR>
nnoremap <silent> <leader>tr :TidyTermPosition right<CR>
nnoremap <silent> <leader>tf :TidyTermPosition floating<CR>
```

---

## How It Works

- Press your mapping (e.g., `Ctrl-/`) in normal or terminal mode to show or hide the terminal.
- When showing, you’re dropped directly into terminal-insert mode (ready to type commands).
- When hiding, your previous window is restored.
- If autostart is enabled, the terminal opens automatically on Vim/Neovim startup.

---

## Example Workflows

### Basic Workflow
1. Press `Ctrl-/` to open your default terminal
2. Run shell commands or scripts
3. Press `Ctrl-/` again to hide and return to editing
4. Terminal persists across toggles

### Multiple Terminal Workflow
1. Use `:TidyTerm dev` to open a development terminal
2. Use `:TidyTerm test` to open a testing terminal
3. Use `:TidyTerm build` for build operations
4. Switch between terminals with `:TidyTermNext` and `:TidyTermPrev`
5. View all terminals with `:TidyTermList`

### Git Integration Workflow
1. Press `<leader>gs` to check git status
2. Press `<leader>ga` to stage all changes
3. Press `<leader>gc` to commit with a message
4. Press `<leader>gp` to push changes
5. All operations happen in dedicated terminals

### Development Workflow
1. Use `:TidyTermBuild` to build your project
2. Use `:TidyTermRun` to start your application
3. Use `:TidyTermTest` to run tests
4. Send code snippets with visual selection + `<leader>ts`
5. Switch terminal positions with `:TidyTermPosition floating`

### Session Management Workflow
1. TidyTerm automatically detects your project
2. Creates project-specific terminal sessions
3. Persists terminals across Vim restarts
4. Switch between projects with `:TidyTermSession <name>`
5. Clean up inactive terminals with `:TidyTermClean`

---

## Configuration

TidyTerm offers extensive customization options. Add these to your `vimrc` or `init.vim`:

### Basic Configuration
```vim
" Automatically open the terminal when Vim/Neovim starts
let g:tidyterm_autostart = 1

" Set terminal position: 'bottom', 'top', 'left', 'right', or 'floating'
let g:tidyterm_position = 'right'

" Set the size of the terminal split
let g:tidyterm_size = 30

" Set filetype for terminal buffer
let g:tidyterm_filetype = 'sh'
```

### Advanced Configuration
```vim
" Session persistence (save/restore terminals across restarts)
let g:tidyterm_session_persistence = 1

" Enable floating windows (Neovim only)
let g:tidyterm_floating_window = 1
let g:tidyterm_floating_width = 0.8
let g:tidyterm_floating_height = 0.6
let g:tidyterm_floating_border = 'rounded'

" Smart positioning (auto-adjust based on window layout)
let g:tidyterm_smart_position = 1

" Focus terminal when toggling
let g:tidyterm_focus_on_toggle = 1

" Remember terminal sizes per position
let g:tidyterm_remember_size = 1

" Statusline integration
let g:tidyterm_statusline_integration = 1

" Command history size
let g:tidyterm_history_size = 100

" Shell integration features
let g:tidyterm_shell_integration = 1

" Auto-change directory to project root
let g:tidyterm_auto_cd = 1

" Show terminal title
let g:tidyterm_terminal_title = 1

" Quick commands
let g:tidyterm_quick_commands = {
    \ 'serve': 'python -m http.server 8000',
    \ 'lint': 'eslint .',
    \ 'format': 'prettier --write .'
    \ }
```

### Position Options

| Value   | Description                    | Vim Support | Neovim Support |
|---------|--------------------------------|-------------|----------------|
| `bottom` | Terminal appears below the editor (horizontal split) | ✓ | ✓ |
| `top`    | Terminal appears above the editor (horizontal split) | ✓ | ✓ |
| `left`   | Terminal appears on the left side (vertical split)   | ✓ | ✓ |
| `right`  | Terminal appears on the right side (vertical split)  | ✓ | ✓ |
| `floating` | Terminal appears as a floating window | ✗ | ✓ |

### Floating Window Options

| Option | Description | Default |
|--------|-------------|--------|
| `floating_width` | Width as percentage of screen (0.1-1.0) | 0.8 |
| `floating_height` | Height as percentage of screen (0.1-1.0) | 0.6 |
| `floating_border` | Border style: 'none', 'single', 'double', 'rounded', 'solid', 'shadow' | 'rounded' |

### Session Management

TidyTerm automatically manages terminal sessions per project:

- **Project Detection**: Automatically detects projects using `.git`, `package.json`, `Cargo.toml`, etc.
- **Session Persistence**: Saves terminal state across Vim restarts
- **Multiple Sessions**: Switch between different project sessions
- **Clean-up**: Automatically removes inactive terminals

### Integration Features

#### Git Integration
Automatically detects Git repositories and provides shortcuts for common operations:
- Status checking
- Staging changes
- Committing with messages
- Push/pull operations
- Log viewing
- Diff display

#### Build System Integration
Auto-detects build systems and provides appropriate commands:
- **Node.js**: `npm run build`, `npm run dev`, `npm start`
- **Rust**: `cargo build`, `cargo run`, `cargo test`
- **Go**: `go build`, `go run`, `go test`
- **Python**: `python setup.py build`, `pip install -e .`
- **Make**: `make`, `make clean`, `make install`

#### Test Framework Integration
Supports popular test frameworks:
- **JavaScript**: `npm test`, `npm run test:watch`
- **Rust**: `cargo test`, `cargo test --nocapture`
- **Go**: `go test ./...`, `go test -v`
- **Python**: `pytest`, `pytest -v`, `pytest --cov`

### Statusline Integration

TidyTerm can integrate with popular statusline plugins:

#### Airline Integration
```vim
" Automatically integrates with vim-airline
let g:tidyterm_statusline_integration = 1
```

#### Lightline Integration
```vim
let g:lightline = {
    \ 'component_function': {
    \   'tidyterm': 'tidyterm#statusline#GetCompactString'
    \ }
    \ }
```

#### Custom Statusline
```vim
set statusline+=%{tidyterm#statusline#GetStatusString()}
```

---

## Compatibility

- **Neovim**
- **Vim 8+**

---

## Contributing

Contributions are welcome!  
Feel free to open [issues](https://github.com/josstei/vim-tidyterm/issues) or [pull requests](https://github.com/josstei/vim-tidyterm/pulls) for improvements or bug fixes.

---

## License

[MIT License](LICENSE)
