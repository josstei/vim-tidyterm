![Stable](https://img.shields.io/badge/status-stable-brightgreen) ![License](https://img.shields.io/badge/license-MIT-blue)

# vim-tidyterm

**A lightweight Vim/Neovim plugin for quickly toggling a dedicated terminal buffer.**

---

## Features

- Quickly toggle (show/hide) a persistent terminal buffer in Vim or Neovim.
- Optionally autostart the terminal when Vim/Neovim opens.
- Configurable terminal position and size.
- Remembers your previous window and returns you there when hiding the terminal.
- Compatible with both Vim and Neovim, handling their differences in terminal mode behavior.
- Simple key mappings for seamless workflow integration.

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

### Command

```vim
:TidyTerm
```

Toggles the dedicated terminal window.

### Example Key Mapping Setup

Add the following to your `vimrc` or `init.vim` for fast toggling:

```vim
" Normal mode: toggle terminal with Ctrl-/
nnoremap <silent> <C-_> :TidyTerm<CR>

" Terminal mode: toggle terminal with Ctrl-/
tnoremap <silent> <C-_> <C-\><C-n>:TidyTerm<CR>
```

---

## How It Works

- Press your mapping (e.g., `Ctrl-/`) in normal or terminal mode to show or hide the terminal.
- When showing, you’re dropped directly into terminal-insert mode (ready to type commands).
- When hiding, your previous window is restored.
- If autostart is enabled, the terminal opens automatically on Vim/Neovim startup.

---

## Example Workflow

1. Press `Ctrl-/` to open your terminal at the bottom (or your configured position).
2. Run shell commands or scripts.
3. Press `Ctrl-/` again to hide the terminal and return to your editing window.
4. Repeat as needed — the terminal buffer persists across toggles.

---

## Configuration

While the plugin works out of the box, several options are available for customization. Add these to your `vimrc` or `init.vim`:

```vim
" Automatically open the terminal when Vim/Neovim starts
" Default: 0 (disabled)
let g:tidyterm_autostart = 1

" Set terminal position: 'bottom', 'top', 'left', or 'right'
" Default: 'bottom'
let g:tidyterm_position = 'left'

" Set the size of the terminal split (height or width depending on position)
" Default: 20
let g:tidyterm_size = 30
```

### Position Options

| Value   | Description                    |
|---------|--------------------------------|
| `bottom` | Terminal appears below the editor (horizontal split) |
| `top`    | Terminal appears above the editor (horizontal split) |
| `left`   | Terminal appears on the left side (vertical split)   |
| `right`  | Terminal appears on the right side (vertical split)  |

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
