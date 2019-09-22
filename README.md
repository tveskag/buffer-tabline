#buffer-tabline

Small simple plugin to display buffer names and tabpages. Also lets you rename tabs.

### Installation:
Use a plugin manager like [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'tveskag/buffer-tabline'
```

### Usage:

![example gif](https://github.com/tveskag/buffer-tabline/blob/master/img/example.gif "Example gif")

#### Functions
The plugin is exposed through the functions:

TablineNextBuffer, 
TablinePrevBuffer, 
TablineDeleBuffer, 
TablineRenameTab "name", 

example:

```
nmap <silent> <C-k> :TablineNextBuffer<CR>
nmap <silent> <C-j> :TablinePrevBuffer<CR>
nmap <silent> <C-c> :TablineDeleBuffer<CR>:TablinePrevBuffer<CR>

nmap <leader>t :TablineRenameTab '
```

#### Options
 

```
No options. :(
```
